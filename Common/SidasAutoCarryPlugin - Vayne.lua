local Version = "1.0"

require "VPrediction"

local SpellQ = {Range =  300, Speed =   20, Delay = 0.25, Width =   0}
local SpellW = {Range =  750, Speed = 1200, Delay =    0, Width =   0}
local SpellE = {Range =  710, Speed = 1200, Delay = 0.25, Width =   0}
local SpellR = {Range =    0, Speed =   20, Delay = 0.40, Width =   0}
local qReady, wReady, eReady, rReady = false, false, false, false
local ePos = nil
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
	VayneLoad()
	VayneMenu()
end

function PluginOnTick()
	VayneCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			VayneCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			VayneHarass(Target)
		end
	end
	if Menu.SpellESub.DashesE then
		VayneDashes()
	end
	if Menu.SpellESub.CondemnE then
		VayneCondemn()
	end
	VayneKill()
end

function PluginOnProcessSpell(unit, spell)
	if Menu.SpellESub.InterruptE then
		if #Interrupt > 0 then
			for _, Inter in pairs(Interrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if Menu.SpellESub[Inter.spellName] and GetDistance(unit) < SpellE.Range then
						CastSpell(_E, unit)
					end
				end
			end
		end
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawSub.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
		end
		if Menu.DrawSub.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.Range, 0xFFFFFF)
		end
	end
end

function VayneMenu()
	Menu:addSubMenu("---- [ 连招设置 ] ----", "ComboSub")
	Menu.ComboSub:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboR", "连招使用 R", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("---- [ 消耗设置 ] ----", "HarassSub")
	Menu.HarassSub:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassR", "消耗使用 R", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("---- [ 技能设置 ] ----", "SpellSub")
	Menu.SpellSub:addParam("MaxQ", "距离设置 Q", SCRIPT_PARAM_SLICE, 650, 550, 850, -1)
	Menu.SpellSub:addParam("EnemiesR", "人数设置 R", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)

	Menu:addSubMenu("---- [ 恶魔审判 ] ----", "SpellESub")
	Menu.SpellESub:addParam("sep", "---- [ 其他设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellESub:addParam("KillE", "可以击杀时使用", SCRIPT_PARAM_ONOFF, false)
	Menu.SpellESub:addParam("MaxE", "使用的最大距离", SCRIPT_PARAM_SLICE, 200, 0, SpellE.Range, -1)
	Menu.SpellESub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellESub:addParam("sep", "---- [ 自动推墙 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellESub:addParam("CondemnE", "目标靠墙时使用", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("T"))
	Menu.SpellESub:addParam("DistanceE", "推墙的距离设置", SCRIPT_PARAM_SLICE, 350, 0, 470, -1)
	Menu.SpellESub:addParam("AccuracyE", "推墙的精度设置", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
	Menu.SpellESub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellESub:addParam("sep", "---- [ 自动防突 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellESub:addParam("DashesE", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellESub:addParam("RangesE", "目标的距离小于", SCRIPT_PARAM_SLICE, 500, 0, SpellE.Range, -1)
	Menu.SpellESub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellESub:addParam("sep", "---- [ 自动打断 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellESub:addParam("InterruptE", "目标大招时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellESub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellESub:addParam("sep", "---- [ 打断列表 ] ----", SCRIPT_PARAM_INFO, "")
	if #Interrupt > 0 then
		for _, Inter in pairs(Interrupt) do
			Menu.SpellESub:addParam(Inter.spellName, Inter.charName.." → "..Inter.spellName, SCRIPT_PARAM_ONOFF, true)
		end
	else
		Menu.SpellESub:addParam("sep", "没有需要打断的英雄技能", SCRIPT_PARAM_INFO, "")
	end

	Menu:addSubMenu("---- [ 显示设置 ] ----", "DrawSub")
	Menu.DrawSub:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	
	Menu.SpellESub:permaShow("CondemnE")
end

function VayneLoad()
	AutoCarry.SkillsCrosshair.range = 850
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
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

function VayneCheck()
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

function VayneCombo(unit)
	if qReady and Menu.ComboSub.ComboQ and GetDistance(unit) < Menu.SpellSub.MaxQ and AttackReset() then
		CastSpell(_Q, mousePos.x, mousePos.z)
	end
	if eReady and Menu.ComboSub.ComboE and GetDistance(unit) < Menu.SpellESub.MaxE then
		CastSpell(_E, unit)
	end
	if rReady and Menu.ComboSub.ComboR and GetDistance(unit) < 850 and CountEnemyHeroInRange(850) >= Menu.EnemiesR then
		CastSpell(_R)
	end
end

function VayneHarass(unit)
	if qReady and Menu.HarassSub.HarassQ and GetDistance(unit) < Menu.SpellSub.MaxQ and AttackReset() then
		CastSpell(_Q, mousePos.x, mousePos.z)
	end
	if eReady and Menu.HarassSub.HarassE and GetDistance(unit) < Menu.SpellESub.MaxE then
		CastSpell(_E, unit)
	end
	if rReady and Menu.HarassSub.HarassR and GetDistance(unit) < 850 and CountEnemyHeroInRange(850) >= Menu.EnemiesR then
		CastSpell(_R)
	end
end

function VayneKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.SpellESub.KillE and GetDistance(enemy) < SpellE.Range and eDmg > enemy.health then
				CastSpell(_E, enemy)
			end
		end
	end
end

function VayneDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
			if IsDashing and CanHit and eReady and GetDistance(Position) < Menu.SpellESub.RangesE then
				CastSpell(_E, enemy)
			end
		end
	end
end

function VayneCondemn()
	for _, enemy in ipairs(Enemies) do
		if eReady and not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < 850 then
			local PredictedPos, EnemyHit = VP:GetPredictedPos(enemy, SpellE.Delay, SpellE.Speed, myHero, false)
			local CastPosition, SkillHit, Position = VP:GetLineCastPosition(enemy, SpellE.Delay, SpellE.Width, SpellE.Range, SpellE.Speed, myHero, false)
			if SkillHit >= 2 then
				ePos = Position
			elseif EnemyHit >= 2 then
				ePos = PredictedPos
			else
				ePos = nil
			end
			if ePos ~= nil then
				local Checks = math.ceil(Menu.SpellESub.AccuracyE)
				local CheckDistance = math.ceil(Menu.SpellESub.DistanceE / Checks)
				local InsideTheWall = false
				for k = 1, Checks, 1 do
					local EnemyPosition = ePos + (Vector(ePos) - myHero):normalized() * (CheckDistance * k)
					local SkillPosition = Vector(ePos) + Vector(Vector(ePos) - Vector(myHero)):normalized() * (CheckDistance * k)
					local EnemyWall = IsWall(D3DXVECTOR3(EnemyPosition.x, EnemyPosition.y, EnemyPosition.z))
					local SkillWall = IsWall(D3DXVECTOR3(SkillPosition.x, SkillPosition.y, SkillPosition.z))
					if EnemyWall or SkillWall then
						InsideTheWall = true
						break
					end
				end
				if InsideTheWall then
					CastSpell(_E, enemy)
				end
			end
		end
	end
end

function AttackReset()
	if AutoCarry.shotFired or AutoCarry.Orbwalker:IsAfterAttack() then
		return true
	else
		return false
	end
end