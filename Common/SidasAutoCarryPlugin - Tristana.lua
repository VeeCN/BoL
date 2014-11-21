local Version = "1.0"

require "VPrediction"

local SpellQ = {Range =  703, Speed = 1450, Delay = 0.50, Width =   0}
local SpellW = {Range =  900, Speed =   20, Delay = 0.25, Width =   0}
local SpellE = {Range =  703, Speed = 1400, Delay = 0.25, Width =   0}
local SpellR = {Range =  703, Speed = 1600, Delay = 0.25, Width =   0}
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
	TristanaLoad()
	TristanaMenu()
end

function PluginOnTick()
	TristanaCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			TristanaCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			TristanaHarass(Target)
		end
	end
	if Menu.DashesR then
		TristanaDashes()
	end
	TristanaKill()
end

function PluginOnProcessSpell(unit, spell)
	if Menu.InterruptR then
		if #Interrupt > 0 then
			for _, Inter in pairs(Interrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if Menu[Inter.spellName] and GetDistance(unit) < SpellR.Range then
						CastSpell(_R, unit)
					end
				end
			end
		end
	end
end

function PluginOnDraw()
	if not myHero.dead then
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

function TristanaMenu()
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboR", "连招使用 R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassR", "消耗使用 R", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 毁灭射击 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillR", "可以击杀时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("MaxR", "使用的最大距离", SCRIPT_PARAM_SLICE, 200, 0, SpellR.Range, -1)
	Menu:addParam("DashesR", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesR", "突进的距离小于", SCRIPT_PARAM_SLICE, 500, 0, SpellR.Range, -1)
	Menu:addParam("InterruptR", "目标大招时使用", SCRIPT_PARAM_ONOFF, true)
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
	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
end

function TristanaLoad()
	AutoCarry.SkillsCrosshair.range = 900
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

function TristanaCheck()
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

function TristanaCombo(unit)
	if qReady and Menu.ComboQ and GetDistance(unit) < SpellQ.Range then
		CastVPredQ(unit)
	end
	if eReady and Menu.ComboE and GetDistance(unit) < SpellE.Range then
		CastSpell(_E, unit)
	end
	if rReady and Menu.ComboR and GetDistance(unit) < Menu.MaxR then
		CastSpell(_R, unit)
	end
end

function TristanaHarass(unit)
	if qReady and Menu.HarassQ and GetDistance(unit) < SpellQ.Range then
		CastVPredQ(unit)
	end
	if eReady and Menu.HarassE and GetDistance(unit) < SpellE.Range then
		CastSpell(_E, unit)
	end
	if rReady and Menu.HarassR and GetDistance(unit) < Menu.MaxR then
		CastSpell(_R, unit)
	end
end

function TristanaKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillR and GetDistance(enemy) < SpellR.Range and rDmg > enemy.health then
				CastSpell(_R, enemy)
			end
		end
	end
end

function TristanaDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellR.Delay, SpellR.Width, SpellR.Speed, myHero)
			if IsDashing and CanHit and rReady and GetDistance(Position) < Menu.RangesR then
				CastSpell(_R, enemy)
			end
		end
	end
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellQ.Delay, SpellQ.Speed, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil and GetDistance(unit) < SpellQ.Range then
			if (GetDistance(PredictedPos) < SpellQ.Range + VP:GetHitBox(unit)) or (GetDistance(unit) < SpellQ.Range + VP:GetHitBox(unit)) then
				CastSpell(_Q)
			end
		end
	end
end