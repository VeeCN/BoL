local Version = 1.0

require "VPrediction"

function PluginOnLoad()
	VayneLoad()
	VayneMenu()
end

function PluginOnTick()
	VayneCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboSub.ComboQ and GetDistance(Target) < 850 and ResetAttack() then
				CastSpell(_Q, mousePos.x, mousePos.z)
			end
			if eReady and Menu.ComboSub.ComboE and GetDistance(Target) < Menu.ExtrasSub.RangesE then
				CastSpell(_E, Target)
			end
			if rReady and Menu.ComboSub.ComboR and GetDistance(Target) < 850 and CountEnemyHeroInRange(850) >= Menu.ExtrasSub.EnemiesR then
				CastSpell(_R)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassSub.HarassQ and GetDistance(Target) < 850 and ResetAttack() then
				CastSpell(_Q, mousePos.x, mousePos.z)
			end
			if eReady and Menu.HarassSub.HarassE and GetDistance(Target) < Menu.ExtrasSub.RangesE then
				CastSpell(_E, Target)
			end
			if rReady and Menu.HarassSub.HarassR and GetDistance(Target) < 850 and CountEnemyHeroInRange(850) >= Menu.ExtrasSub.EnemiesR then
				CastSpell(_R)
			end
		end
	end
	if Menu.SpellESub.DashesE and (Menu2.AutoCarry or Menu2.MixedMode or VayneHealthLow()) then
		VayneDashes()
	end
	if Menu.SpellESub.CondemnE and (Menu2.AutoCarry or Menu2.MixedMode or VayneHealthLow()) then
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
	Menu.ComboSub:addParam("ComboR", "连招使用 R", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ 消耗设置 ] ----", "HarassSub")
	Menu.HarassSub:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassR", "消耗使用 R", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("---- [ 高级设置 ] ----", "ExtrasSub")
	Menu.ExtrasSub:addParam("KillE", "击杀使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.ExtrasSub:addParam("RangesE", "距离设置 E", SCRIPT_PARAM_SLICE, 250, 0, SpellE.Range, -1)
	Menu.ExtrasSub:addParam("EnemiesR", "人数设置 R", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)

	Menu:addSubMenu("---- [ 恶魔审判 ] ----", "SpellESub")
	Menu.SpellESub:addParam("sep", "---- [ 自动推墙 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellESub:addParam("CondemnE", "目标靠墙时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellESub:addParam("DistanceE", "推墙的距离设置", SCRIPT_PARAM_SLICE, 350, 0, 450, -1)
	Menu.SpellESub:addParam("AccuracyE", "推墙的精度设置", SCRIPT_PARAM_SLICE, 25, 1, 50, 0)
	Menu.SpellESub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.SpellESub:addParam("sep", "---- [ 自动防突 ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellESub:addParam("DashesE", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellESub:addParam("RangesE", "目标的距离小于", SCRIPT_PARAM_SLICE, 500, 0, SpellE.Range, -1)
	Menu.SpellESub:addParam("HealthE", "自己的血量小于", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
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
	Menu.SpellESub:permaShow("DashesE")
	Menu.SpellESub:permaShow("InterruptE")
end

function VayneLoad()
	AutoCarry.SkillsCrosshair.range = 850
	SpellQ = {Range =  300, Speed =   20, Delay = 0.25, Width =  50}
	SpellW = {Range =  750, Speed = 1200, Delay =    0, Width =  50}
	SpellE = {Range =  710, Speed = 1200, Delay = 0.25, Width =   0}
	SpellR = {Range =    0, Speed =   20, Delay = 0.40, Width =   0}
	qReady, wReady, eReady, rReady = false, false, false, false
	ePos = nil
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

function VayneKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.ExtrasSub.KillE and GetDistance(enemy) < SpellE.Range and eDmg > enemy.health then
				CastSpell(_E, enemy)
			end
		end
	end
end

function VayneDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
			if IsDashing and CanHit and eReady and GetDistance(enemy) < Menu.SpellESub.RangesE then
				CastSpell(_E, enemy)
			end
		end
	end
end

function VayneCondemn()
	for _, enemy in ipairs(Enemies) do
		if eReady and not enemy.dead and ValidTarget(enemy) then
			local CastPosition, SkillHit, Position = VP:GetLineCastPosition(enemy, SpellE.Delay, SpellE.Width, SpellE.Range, SpellE.Speed, myHero, false)
			local PredictedPos, EnemyHit = VP:GetPredictedPos(enemy, SpellE.Delay, SpellE.Speed, myHero, false)
			if GetDistance(enemy) < SpellE.Range then
				if SkillHit >= 1 then
					ePos = Position
				elseif EnemyHit >= 1 then
					ePos = PredictedPos
				else
					ePos = nil
				end
			end
			if ePos ~= nil then
				local Checks = math.ceil(Menu.SpellESub.AccuracyE)
				local CheckDistance = math.ceil(Menu.SpellESub.DistanceE / Checks)
				local InsideTheWall = false
				for k = 1, Checks, 1 do
					local SkillPosition = Vector(ePos) + Vector(Vector(ePos) - Vector(myHero)):normalized() * (CheckDistance * k)
					local EnemyPosition = ePos + (Vector(ePos) - myHero):normalized() * (CheckDistance * k)
					local SkillWall = IsWall(D3DXVECTOR3(SkillPosition.x, SkillPosition.y, SkillPosition.z))
					local EnemyWall = IsWall(D3DXVECTOR3(EnemyPosition.x, EnemyPosition.y, EnemyPosition.z))
					if SkillWall or EnemyWall then
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

function VayneHealthLow()
	if (myHero.health / myHero.maxHealth) < (Menu.SpellESub.HealthE / 100) then
		return true
	else
		return false
	end
end

function ResetAttack()
	if AutoCarry.shotFired or AutoCarry.Orbwalker:IsAfterAttack() then
		return true
	else
		return false
	end
end