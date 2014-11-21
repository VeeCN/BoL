local Version = "1.0"

require "VPrediction"

local SpellQ = {Range = 1450, Speed = 1450, Delay = 0.25, Width =  60}
local SpellW = {Range =  525, Speed =    0, Delay = 0.25, Width =   0}
local SpellE = {Range =  525, Speed =    0, Delay = 0.25, Width =   0}
local SpellR = {Range = 5500, Speed =    0, Delay = 0.25, Width =   0}
local qReady, wReady, eReady, rReady = false, false, false, false

function PluginOnLoad()
	TwistedFateLoad()
	TwistedFateMenu()
end

function PluginOnTick()
	TwistedFateCheck()
	TwistedFateCardSelect()
	TwistedFateRSelectCard()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			TwistedFateCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			TwistedFateHarass(Target)
		end
	end
	if Menu.DashesW then
		TwistedFateDashes()
	end
	if Menu.ImmobileQ or ImmobileW then
		TwistedFateImmobile()
	end
	TwistedFateKill()
end

function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "gate" then
		if Menu.AutoR then
			RSelectCard = true
		end
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
		end
	end
end

function TwistedFateMenu()
	Menu:addParam("sep", "---- [ 万能牌 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassQ", "消耗使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillQ", "击杀使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("DrawQ", "范围显示", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("ImmobileQ", "目标禁锢时使用", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("MaxQ", "使用的最大距离", SCRIPT_PARAM_SLICE, 700, 0, SpellQ.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 选牌 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("GoldW", "选择黄牌", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	Menu:addParam("RedW", "选择红牌", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G"))
	Menu:addParam("BlueW", "选择蓝牌", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("Z"))
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("AutoComboW", "连招模式自动选牌", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("AutoHarassW", "消耗模式自动选牌", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("RedEnemies", "自动选牌红牌人数", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("GoldHealth", "自动选牌黄牌血量", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Menu:addParam("BlueMana", "自动选牌蓝牌蓝量", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("DashesW", "目标突进时选择黄牌", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ImmobileW", "目标禁锢时选择黄牌", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 命运 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("AutoR", "大招自动选牌", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("SelectR", "大招落地使用", SCRIPT_PARAM_LIST, 1, {"黄牌", "红牌", "蓝牌"})

	Menu:permaShow("GoldW")
	Menu:permaShow("RedW")
	Menu:permaShow("BlueW")
end

function TwistedFateLoad()
	AutoCarry.SkillsCrosshair.range = 1450
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function TwistedFateCheck()
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

function TwistedFateCombo(unit)
	if qReady and Menu.ComboQ and GetDistance(unit) < Menu.MaxQ then
		CastVPredQ(unit)
	end
	if wReady and Menu.AutoComboW then
		AutoW()
	end
end

function TwistedFateHarass(unit)
	if qReady and Menu.HarassQ and GetDistance(unit) < Menu.MaxQ then
		CastVPredQ(unit)
	end
	if wReady and Menu.AutoHarassW then
		AutoW()
	end
end

function TwistedFateKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillQ and qDmg > enemy.health and GetDistance(enemy) < SpellQ.Range then
				CastVPredQ(enemy)
			end
		end
	end
end

function TwistedFateDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
			if IsDashing and CanHit and wReady and GetDistance(Position) < SpellW.Range then
				if myHero:GetSpellData(_W).name == "goldcardlock" then
					CastSpell(_W)
				elseif myHero:GetSpellData(_W).name == "PickACard" then
					CastSpell(_W)
				end
			end
		end
	end
end

function TwistedFateImmobile()
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
					if myHero:GetSpellData(_W).name == "goldcardlock" then
						CastSpell(_W)
					elseif myHero:GetSpellData(_W).name == "PickACard" then
						CastSpell(_W)
					end
				end
			end
		end
	end
end

function TwistedFateHealthLow()
	if (myHero.health / myHero.maxHealth) < (Menu.GoldHealth / 100) then
		return true
	else
		return false
	end
end

function TwistedFateManaLow()
	if (myHero.mana / myHero.maxMana) < (Menu.BlueMana / 100) then
		return true
	else
		return false
	end
end

function TwistedFateCardSelect()
	local Name = myHero:GetSpellData(_W).name

	if Menu.BlueW then
		SelectCard = "Blue"
	else
		if not Menu.RedW and not Menu.GoldW then
			SelectCard = nil
		end
	end

	if Menu.RedW then
		SelectCard = "Red"
	else
		if not Menu.BlueW and not Menu.GoldW then
			SelectCard = nil
		end
	end

	if Menu.GoldW then
		SelectCard = "Gold"
	else
		if not Menu.RedW and not Menu.BlueW then
			SelectCard = nil
		end
	end

	if SelectCard == "Blue" then
		spellName = "bluecardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if SelectCard == "Red" then
		spellName = "redcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if SelectCard == "Gold" then
		spellName = "goldcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if Name == spellName then
		CastSpell(_W)
		SelectCard = nil
	end
end

function TwistedFateRSelectCard()
	if RSelectCard == true then
		if Menu.SelectR == 1 then
			if myHero:GetSpellData(_W).name == "goldcardlock" then
				CastSpell(_W)
				RSelectCard = false
			elseif myHero:GetSpellData(_W).name == "PickACard" then
				CastSpell(_W)
			end
		end
		if Menu.SelectR == 2 then
			if myHero:GetSpellData(_W).name == "redcardlock" then
				CastSpell(_W)
				RSelectCard = false
			elseif myHero:GetSpellData(_W).name == "PickACard" then
				CastSpell(_W)
			end
		end
		if Menu.SelectR == 3 then
			if myHero:GetSpellData(_W).name == "bluecardlock" then
				CastSpell(_W)
				RSelectCard = false
			elseif myHero:GetSpellData(_W).name == "PickACard" then
				CastSpell(_W)
			end
		end
	end
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
	local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellW.Delay, SpellW.Speed, myHero, false)
	if PredictedPos ~= nil and HitChance ~= nil and GetDistance(unit) < 900 then
		if GetDistance(PredictedPos) > 500 or GetDistance(unit) > 500 then
			return true
		elseif GetDistance(PredictedPos) < 300 or GetDistance(unit) < 300 then
			return true
		else
			return false
		end
	end
end

function AutoW()
	for _, enemy in ipairs(Enemies) do
		if ValidTarget(enemy, 900) and not enemy.dead then
			if myHero:GetSpellData(_W).name == "PickACard" then
				CastSpell(_W)
			end
			if TwistedFateHealthLow() or EnemiesPrePos(enemy) then
				spellName = "goldcardlock"
				if Name == "PickACard" then
					CastSpell(_W)
				end
			end
			if TwistedFateManaLow() and not TwistedFateHealthLow() then
				spellName = "bluecardlock"
				if Name == "PickACard" then
					CastSpell(_W)
				end
			end
			if CountEnemies(100, enemy) >= Menu.RedEnemies and not TwistedFateHealthLow() then
				spellName = "redcardlock"
				if Name == "PickACard" then
					CastSpell(_W)
				end
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