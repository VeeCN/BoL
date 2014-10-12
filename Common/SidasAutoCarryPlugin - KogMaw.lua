local version = "0.11"

require "VPrediction"

local VP = VPrediction()
local SpellQ = {Speed = 1550, Range = 1000, Delay = 0.3667, Width = 60}
local SpellW = {Speed = 1600, Range = 1000, Delay = 0.111, Width = 55}
local SpellE = {Speed = 1400, Range = 1280, Delay = 0.066, Width = 120}
local SpellR = {Width = 150, Speed = math.huge, Delay= 1.1}
local RRangeTable = {1200, 1500, 1800}
local WRange, RRange = nil, nil
local QReady, WReady, EReady, RReady = nil, nil, nil, nil
local RStacks = 0
local WRangeTable = {130, 150, 170, 190, 210}

function KogMawMenu()
	Menu:addSubMenu("---- [ 连招设置 ] ----", "ComboSub")
	Menu:addSubMenu("---- [ 消耗设置 ] ----", "HarassSub")
	Menu:addSubMenu("---- [ 补兵设置 ] ----", "FarmSub")
	Menu:addSubMenu("---- [ 击杀设置 ] ----", "KSSub")
	Menu:addSubMenu("---- [ 高级设置 ] ----", "ExtrasSub")
	Menu:addSubMenu("---- [ 显示设置 ] ----", "DrawSub")
	--Combo
	Menu.ComboSub:addParam("useQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("useW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("useE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("useR", "连招使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("mManager", "蓝耗管理 %", SCRIPT_PARAM_SLICE, 0, 0, 100, -1)
	--Harass
	Menu.HarassSub:addParam("useQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("useW", "消耗使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("useE", "消耗使用 E", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("useR", "消耗使用 R", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("mManager", "蓝耗管理 %", SCRIPT_PARAM_SLICE, 0, 0, 100, -1)
	--Farm
	Menu.FarmSub:addParam("useE", "补兵使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.FarmSub:addParam("useW", "补兵使用 W", SCRIPT_PARAM_ONOFF, true)
	--KS
	Menu.KSSub:addParam("useQ", "击杀使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.KSSub:addParam("useE", "击杀使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.KSSub:addParam("useR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)
	--Draw
	Menu.DrawSub:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
	--Extras
	Menu.ExtrasSub:addParam("sep", "---- [ 虚空淤泥 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("EDashes", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.ExtrasSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("sep", "---- [ 活体大炮 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("RStacks1", "一级最大层数", SCRIPT_PARAM_SLICE, 2, 1, 10, 0)
	Menu.ExtrasSub:addParam("RStacks2", "二级最大层数", SCRIPT_PARAM_SLICE, 3, 1, 10, 0)
	Menu.ExtrasSub:addParam("RStacks3", "三级最大层数", SCRIPT_PARAM_SLICE, 4, 1, 10, 0)
	Menu.ExtrasSub:addParam("RMinRange", "使用最小范围", SCRIPT_PARAM_SLICE, 500, 0, 1800, -1)
	Menu.ExtrasSub:addParam("AutoUlt", "使用完美命中", SCRIPT_PARAM_ONOFF, false)
	Menu.ExtrasSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("sep", "---- [ 其他设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.ExtrasSub:addParam("Debug", "调试模式", SCRIPT_PARAM_ONOFF, false)
end

function KogMawLoad()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	AutoCarry.SkillsCrosshair.range = 1280
	EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
end

function PluginOnLoad()
	KogMawLoad()
	KogMawMenu()
end

function PluginOnTick()
	EnemyMinions:update()
	Check()
	if Menu2.AutoCarry and Target ~= nil then
		Combo(Target)
	elseif Menu2.AutoCarry and QTarget ~= nil then
		Combo(QTarget)
	end
	if (Menu2.MixedMode or Menu2.LaneClear) and Target ~= nil then
		Harass(Target)
	elseif (Menu2.MixedMode or Menu2.LaneClear) and QTarget ~= nil then
		Harass(QTarget)
	end
	if Menu2.LastHit then
		Farm()
	end
	if Menu.ExtrasSub.EDashes then
		CheckDashes()
	end
	if Menu.ExtrasSub.AutoUlt then
		AutoUlt()
	end
	KillSteal()
end

function Combo(Target)
	if QReady and Menu.ComboSub.useQ and not IsMyManaLowCombo() then
		CastQ(Target)
	end
	if WReady and Menu.ComboSub.useW then
		CastW(Target)
	end
	if EReady and Menu.ComboSub.useE and not IsMyManaLowCombo()then
		CastE(Target)
	end
	if RReady and Menu.ComboSub.useR and StackCheck() and not IsMyManaLowCombo() and GetDistance(Target) > Menu.ExtrasSub.RMinRange then
		CastR(Target)
	end
end

function Harass(Target)
	if QReady and Menu.HarassSub.useQ and not IsMyManaLowHarass() then
		CastQ(Target)
	end
	if WReady and Menu.HarassSub.useW then
		CastW(Target)
	end
	if EReady and Menu.HarassSub.useE and not IsMyManaLowHarass() then
		CastE(Target)
	end
	if RReady and Menu.HarassSub.useR and StackCheck() and not IsMyManaLowHarass() and GetDistance(Target) > Menu.ExtrasSub.RMinRange then
		CastR(Target)
	end
end

function CastQ(Target)
	if Target ~= nil and ValidTarget(Target, 1300) and QReady then
		local CastPosition, HitChance, Pos = VP:GetLineCastPosition(Target, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastW(Target)
	if Target ~= nil and ValidTarget(Target, 1300) and WReady and GetDistance(Target) < WRange then
		CastSpell(_W)
	end
end

function CastE(Target)
	if Target ~= nil and ValidTarget(Target, 1300) and EReady then
		local CastPosition, HitChance, Pos = VP:GetLineAOECastPosition(Target, SpellE.Delay, SpellE.Width, SpellE.Range, SpellE.Speed, myHero)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellE.Range then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

function CastR(Target)
	if RReady and Target ~= nil and ValidTarget(Target, 1800) then
		local CastPosition, HitChance, Pos = VP:GetCircularCastPosition(Target, SpellR.Delay, SpellR.Width, RRange, SpellR.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < RRange and not IsMyManaLowCombo() then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end

function AutoUlt()
	local Enemies = GetEnemyHeroes()
	for i, enemy in ipairs(Enemies) do
		 if ValidTarget(enemy, 1800) and not enemy.dead and GetDistance(enemy) < 1800 then
			local CastPosition, HitChance, Pos = VP:GetCircularCastPosition(enemy, SpellR.Delay, SpellR.Width, RRange, SpellR.Speed, myHero, false)
			if HitChance > 2 and GetDistance(CastPosition) < RRange then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		 end
	end
end

function Farm()
	if Menu.FarmSub.useE then
		FarmE()
	end
	if Menu.FarmSub.useW then
		FarmW()
	end
end

function Reset()
	if _G.MMA_Loaded and _G.MMA_NextAttackAvailability < 0.6 then
		return true
	elseif _G.AutoCarry and (_G.AutoCarry.shotFired or _G.AutoCarry.Orbwalker:IsAfterAttack()) then
		return true
	else
		return false
	end
end

function KillSteal()
	local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do
		if ValidTarget(enemy, 1800) and not enemy.dead and GetDistance(enemy) < 1800 then
			if getDmg("Q", enemy, myHero) > enemy.health and Menu.KSSub.useQ then
				CastQ(enemy)
			end
			if getDmg("E", enemy, myHero) > enemy.health and Menu.KSSub.useE then
				CastE(enemy)
			end
			if getDmg("R", enemy, myHero) > enemy.health and Menu.KSSub.useR then
				CastR(enemy)
			end
		end
	end
end

function PluginOnDraw()
	if Menu.DrawSub.DrawQ then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellQ.Range, 1,  ARGB(255, 0, 255, 255))
	end
	if Menu.DrawSub.DrawW then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, WRange, 1,  ARGB(255, 0, 255, 255))
	end
	if Menu.DrawSub.DrawE then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellE.Range, 1,  ARGB(255, 0, 255, 255))
	end
	if Menu.DrawSub.DrawR then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, RRange, 1,  ARGB(255, 0, 255, 255))
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == 'kogmawlivingartillerycost' then
		RStacks = 1
	end
end

function OnUpdateBuff(unit, buff)
	if unit.isMe and buff.name == 'kogmawlivingartillerycost' then
		RStacks = buff.stack
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == 'kogmawlivingartillerycost' then
		RStacks = 0
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

function Check()
	Target = AutoCarry.GetAttackTarget()
	QTarget = AutoCarry.GetAttackTarget()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	if myHero:GetSpellData(_R).level > 0 then
		RRange = RRangeTable[myHero:GetSpellData(_R).level]
	end
	if myHero:GetSpellData(_W).level > 0 then
		WRange = 500 + WRangeTable[myHero:GetSpellData(_W).level]
	end
end

function countminionshitE(pos)
	local n = 0
	local ExtendedVector = Vector(myHero) + Vector(Vector(pos) - Vector(myHero)):normalized()*SpellE.Range
	for i, minion in ipairs(EnemyMinions.objects) do
		local MinionPointSegment, MinionPointLine, MinionIsOnSegment =  VectorPointProjectionOnLineSegment(Vector(myHero), Vector(ExtendedVector), Vector(minion))
		local MinionPointSegment3D = {x=MinionPointSegment.x, y=pos.y, z=MinionPointSegment.y}
		if MinionIsOnSegment and GetDistance(MinionPointSegment3D, pos) < SpellQ.Width then
			n = n +1
		end
	end
	return n
end

function GetBestEPositionFarm()
	local MaxE = 0
	local MaxEPos
	for i, minion in pairs(EnemyMinions.objects) do
		local hitE = countminionshitE(minion)
		if hitE > MaxE or MaxEPos == nil then
			MaxEPos = minion
			MaxE = hitE
		end
	end
	if MaxEPos then
		return MaxEPos
	else
		return nil
	end
end

function FarmE()
	if EReady and #EnemyMinions.objects > 0 then
		local EPos = GetBestEPositionFarm()
		if EPos then
			CastSpell(_E, EPos.x, EPos.z)
		end
	end
end

function FarmW()
	if WReady and #EnemyMinions.objects > 2 then
		CastSpell(_W)
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
function CheckDashes()
	local Enemies = GetEnemyHeroes()
	for idx, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < SpellE.Range and Menu.ExtrasSub.EDashes then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
			if IsDashing and CanHit and GetDistance(Position) < SpellE.Range and EReady then
				CastSpell(_E, Position.x, Position.z)
			end
		end
	end
end

function IsMyManaLowCombo()
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

function StackCheck()
	local RLevel = myHero:GetSpellData(_R).level
	if (RLevel == 1 and RStacks < Menu.ExtrasSub.RStacks1)
	or (RLevel == 2 and RStacks < Menu.ExtrasSub.RStacks2)
	or (RLevel == 3 and RStacks < Menu.ExtrasSub.RStacks3)
	then
		return true
	else
		return false
	end
end