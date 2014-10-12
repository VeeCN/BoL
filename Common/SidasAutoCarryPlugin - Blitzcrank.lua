require 'VPrediction'

function PluginOnLoad()
	BlitzcrankLoad()
	BlitzcrankMenu()
end

function PluginOnTick()
	BlitzcrankCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboSub.ComboQ and GetDistance(Target) > (SpellE.Range * 2) and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if wReady and Menu.ComboSub.ComboW and GetDistance(Target) < SpellQ.Range then
				CastSpell(_W)
			end
			if eReady and Menu.ComboSub.ComboE and GetDistance(Target) < SpellE.Range then
				CastSpell(_E)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassSub.HarassQ and GetDistance(Target) > (SpellE.Range * 2) and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if wReady and Menu.HarassSub.HarassW and GetDistance(Target) < SpellQ.Range then
				CastSpell(_W)
			end
			if eReady and Menu.HarassSub.HarassE and GetDistance(Target) < SpellE.Range then
				CastSpell(_E)
			end
		end
	end
	if Menu.SpellQSub.DashesQ and (Menu2.AutoCarry or not BlitzcrankHealthLow()) then
		BlitzcrankDashes()
	end
	if Menu.SpellQSub.ImmobileQ and (Menu2.AutoCarry or not BlitzcrankHealthLow()) then
		BlitzcrankImmobile()
	end
	BlitzcrankKill()
end

function PluginOnProcessSpell(unit, spell)
	if Menu.SpellRSub.InterruptR then
		if #Interrupt > 0 then
			for _, Inter in pairs(Interrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if Menu.SpellRSub[Inter.spellName] and GetDistance(unit) < SpellR.Range then
						CastSpell(_R)
					end
				end
			end
		end
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawSub.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFF000000)
		end
		if Menu.DrawSub.DrawR and rReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.Range, 0xFF000000)
		end
	end
end

function BlitzcrankMenu()
	Menu:addSubMenu("---- [ 连招设置 ] ----", "ComboSub")
	Menu.ComboSub:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, false)
	Menu.ComboSub:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ 消耗设置 ] ----", "HarassSub")
	Menu.HarassSub:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ 击杀设置 ] ----", "KillSub")
	Menu.KillSub:addParam("KillQ", "击杀使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.KillSub:addParam("KillR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ 机械飞爪 ] ----", "SpellQSub")
	Menu.SpellQSub:addParam("ImmobileQ", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellQSub:addParam("DashesQ", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellQSub:addParam("RangesQ", "目标的距离小于", SCRIPT_PARAM_SLICE, 920, 0, SpellQ.Range, -1)
	Menu.SpellQSub:addParam("HealthQ", "自己的血量大于", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Menu.SpellQSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.SpellQSub:addParam("sep", "---- [ 抓取列表 ] ----", SCRIPT_PARAM_INFO, "")
	for _, enemy in ipairs(Enemies) do
		if enemy then
			Menu.SpellQSub:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_LIST, 3, {"永不抓取", "普通抓取", "自动抓取"})
		else
			Menu.SpellQSub:addParam("sep", "没有需要抓取的敌方英雄", SCRIPT_PARAM_INFO, "")
		end
	end

	Menu:addSubMenu("---- [ 静电力场 ] ----", "SpellRSub")
	Menu.SpellRSub:addParam("InterruptR", "目标大招时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellRSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.SpellRSub:addParam("sep", "---- [ 打断列表 ] ----", SCRIPT_PARAM_INFO, "")
	if #Interrupt > 0 then
		for _, Inter in pairs(Interrupt) do
			Menu.SpellRSub:addParam(Inter.spellName, Inter.charName.." → "..Inter.spellName, SCRIPT_PARAM_ONOFF, true)
		end
	else
		Menu.SpellRSub:addParam("sep", "没有需要打断的英雄技能", SCRIPT_PARAM_INFO, "")
	end

	Menu:addSubMenu("---- [ 显示设置 ] ----", "DrawSub")
	Menu.DrawSub:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
end

function BlitzcrankLoad()
	AutoCarry.SkillsCrosshair.range = 925
	SpellQ = {Range =  925, Speed = 1800, Delay = 0.25, Width =  70}
	SpellW = {Range =    0, Speed =   20, Delay = 0.40, Width =   0}
	SpellE = {Range =  125, Speed =    0, Delay = 0.50, Width =   0}
	SpellR = {Range =  600, Speed =    0, Delay = 0.25, Width =   0}
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
		{ charName = "TwistedFate", spellName = "gate"}
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

function BlitzcrankCheck()
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

function BlitzcrankKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillSub.KillQ and GetDistance(enemy) < SpellQ.Range and qDmg > enemy.health then
				CastVPredQ(enemy)
			elseif Menu.KillSub.KillR and GetDistance(enemy) < SpellR.Range and rDmg > enemy.health then
				CastSpell(_R)
			end
		end
	end
end

function BlitzcrankDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
			if IsDashing and CanHit and qReady and GetDistance(Position) < Menu.SpellQSub.RangesQ then
				if Menu.SpellQSub[enemy.charName] == 3 and not CheckBLHeroCollision(Position) then
					CastSpell(_Q, Position.x, Position.z)
				end
			end
		end
	end
end

function BlitzcrankImmobile()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsImmobile, Pos = VP:IsImmobile(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
			if IsImmobile and qReady and GetDistance(Pos) > SpellE.Range and GetDistance(Pos) < SpellQ.Range then
				if Menu.SpellQSub[enemy.charName] == 3 and not CheckBLHeroCollision(Pos) then
					CastSpell(_Q, Pos.x, Pos.z)
				end
			end
		end
	end
end

function BlitzcrankHealthLow()
	if (myHero.health / myHero.maxHealth) < (Menu.SpellQSub.HealthQ / 100) then
		return true
	else
		return false
	end
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellQ.Range and not CheckBLHeroCollision(CastPosition) then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CheckBLHeroCollision(Pos)
	for _, enemy in ipairs(Enemies) do
		if ValidTarget(enemy) and GetDistance(enemy) < SpellQ.Range * 1.5 and Menu.SpellQSub[enemy.charName] == 1 then
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(Vector(myHero), Pos, Vector(enemy))
			if (GetDistanceSqr(enemy, proj1) <= (VP:GetHitBox(enemy) * 2 + SpellQ.Width) ^ 2) then
				return true
			end
		end
	end
	return false
end