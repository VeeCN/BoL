local Version = "1.0"

require "VPrediction"

local SpellQ = {Range =    0, Speed =    0, Delay = 0.25, Width =   0}
local SpellW = {Range =  950, Speed = 1400, Delay = 0.25, Width = 206}
local SpellE = {Range = 1200, Speed =    0, Delay = 0.25, Width =   0}
local SpellR = {Range =  850, Speed =  500, Delay = 0.25, Width = 188}
local qReady, wReady, eReady, rReady = false, false, false, false

function PluginOnLoad()
	TwitchLoad()
	TwitchMenu()
end

function PluginOnTick()
	TwitchCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			TwitchCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			TwitchHarass(Target)
		end
	end
	if Menu.DashesW then
		TwitchDashes()
	end
	if Menu.ImmobileW then
		TwitchImmobile()
	end
end

function PluginOnCreateObj(obj)
	if obj and obj.valid and obj.name:lower():find("twitch_poison_counter") then
		for _, enemy in pairs(Enemies) do
			if GetDistance(enemy, obj) <= 80 then
				enemy.RStacks = TwitchGetStacks(obj.name)
				enemy.RTimes = GetTickCount()
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

function TwitchMenu()
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboR", "连招使用 R", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassR", "消耗使用 R", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 剧毒之桶 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DashesW", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ImmobileW", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesW", "使用的最大距离", SCRIPT_PARAM_SLICE, 650, 0, SpellW.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 毒性爆发 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillE", "可以击杀时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangeE", "目标逃跑时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("StacksE", "最大层数时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("MinStacks", "使用的最小层数", SCRIPT_PARAM_SLICE, 4, 1, 6, 0)
	Menu:addParam("MinE", "逃跑的最小距离", SCRIPT_PARAM_SLICE, 1000, 0, SpellE.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 火力全开 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("MaxR", "使用的最大距离", SCRIPT_PARAM_SLICE, 750, 0, SpellR.Range, -1)
	Menu:addParam("EnemiesR", "使用的最小人数", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawW", "显示 W 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "显示 R 范围", SCRIPT_PARAM_ONOFF, false)
end

function TwitchLoad()
	AutoCarry.SkillsCrosshair.range = 1200
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = AutoCarry.EnemyTable
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
	for _, enemy in pairs(Enemies) do
		enemy.RStacks = 0
		enemy.RTimes = 0
	end
end

function TwitchCheck()
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

function TwitchCombo(unit)
	if wReady and Menu.ComboW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.ComboE and GetDistance(unit) < SpellE.Range then
		CastVPredE(unit)
	end
	if rReady and Menu.ComboR and GetDistance(unit) < SpellR.Range then
		CastVPredR(unit)
	end
end

function TwitchHarass(unit)
	if wReady and Menu.HarassW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.HarassE and GetDistance(unit) < SpellE.Range then
		CastVPredE(unit)
	end
	if rReady and Menu.HarassR and GetDistance(unit) < SpellR.Range then
		CastVPredR(unit)
	end
end

function TwitchDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
			if IsDashing and CanHit and wReady and GetDistance(Position) < Menu.RangesW then
				CastSpell(_W, Position.x, Position.z)
			end
		end
	end
end

function TwitchImmobile()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsImmobile, Pos = VP:IsImmobile(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
			if IsImmobile and wReady and GetDistance(Pos) < SpellW.Range then
				CastSpell(_W, Pos.x, Pos.z)
			end
		end
	end
end

function TwitchGetStacks(str)
	for i = 1, 6 do
		if str:lower():find("twitch_poison_counter_0"..i..".troy") then
			return i
		end
	end
	return 0
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

function EnemiesPrePos(unit)
	local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellE.Delay, SpellE.Speed, myHero, false)
	if PredictedPos ~= nil and HitChance ~= nil and GetDistance(unit) < SpellE.Range then
		if (GetDistance(PredictedPos) > Menu.MinE + VP:GetHitBox(unit)) or (GetDistance(unit) > Menu.MinE + VP:GetHitBox(unit)) then
			return true
		else
			return false
		end
	end
end

function CastVPredW(unit)
	if wReady and ValidTarget(unit) then
		local PredictedPos, EnemyHit = VP:GetPredictedPos(unit, SpellW.Delay, SpellW.Speed, myHero, false)
		local CastPosition, SkillHit, Position = VP:GetLineCastPosition(unit, SpellW.Delay, SpellW.Width, Menu.RangesW, SpellW.Speed, myHero, false)
		if SkillHit >= 2 and GetDistance(CastPosition) < Menu.RangesW then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		elseif EnemyHit >= 2 and GetDistance(PredictedPos) < Menu.RangesW then
			CastSpell(_W, PredictedPos.x, PredictedPos.z)
		end
	end
end

function CastVPredE(unit)
	for _, enemy in ipairs(Enemies) do
		local EnemiesPos = EnemiesPrePos(enemy)
		if not enemy.RStacks or (enemy.RStacks > 0 and GetTickCount() > enemy.RTimes + 6500) then
			enemy.RStacks = 0
		elseif enemy.RStacks > 0 and ValidTarget(enemy, SpellE.Range) then
			if (Menu.KillE and eDmg > enemy.health) or (Menu.StacksE and enemy.RStacks == 6) or (Menu.RangeE and EnemiesPrePos(enemy) and enemy.RStacks >= Menu.MinStacks) then
				CastSpell(_E)
				break
			end
		end
	end
end

function CastVPredR(unit)
	for _, enemy in ipairs(Enemies) do
		local PredictedPos, HitChance = VP:GetPredictedPos(enemy, SpellR.Delay, SpellR.Speed, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil and GetDistance(enemy) < SpellR.Range then
			if (GetDistance(PredictedPos) < Menu.MaxR + VP:GetHitBox(enemy)) or (GetDistance(enemy) < Menu.MaxR + VP:GetHitBox(enemy)) then
				if CountEnemies(SpellR.Width, enemy) >= Menu.EnemiesR then
					CastSpell(_R)
				end
			end
		end
	end
end