local Version = "1.0"

require "VPrediction"

local SpellQ = {Range = 1000, Speed = 1200, Delay = 0.25, Width =  53}
local SpellW = {Range =  710, Speed =    7, Delay = 0.25, Width =   0}
local SpellE = {Range = 1280, Speed = 1200, Delay = 0.25, Width =  90}
local SpellR = {Range = 1800, Speed = 2000, Delay = 0.85, Width =  75}
local qReady, wReady, eReady, rReady = false, false, false, false
local RStacks, RTimes = 0, 0

function PluginOnLoad()
	KogMawLoad()
	KogMawMenu()
end

function PluginOnTick()
	KogMawCheck()
	StacksReset()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			KogMawCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			KogMawHarass(Target)
		end
	end
	if Menu.SpellSub.DashesQ or Menu.SpellSub.DashesE then
		KogMawDashes()
	end
	KogMawKill()
end

function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower():find("kogmawlivingartillery") then
		RStacks = RStacks + 1
		RTimes = GetTickCount()
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawSub.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
		end
		if Menu.DrawSub.DrawW and wReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.Range, 0xFFFFFF)
		end
		if Menu.DrawSub.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.Range, 0xFFFFFF)
		end
		if Menu.DrawSub.DrawR and rReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.Range, 0xFFFFFF)
		end
	end
end

function KogMawMenu()
	Menu:addSubMenu("---- [ �������� ] ----", "ComboSub")
	Menu.ComboSub:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboR", "����ʹ�� R", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ �������� ] ----", "HarassSub")
	Menu.HarassSub:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("HarassW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("HarassR", "����ʹ�� R", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("---- [ ��ɱ���� ] ----", "KillSub")
	Menu.KillSub:addParam("KillQ", "��ɱʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu.KillSub:addParam("KillE", "��ɱʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu.KillSub:addParam("KillR", "��ɱʹ�� R", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ �������� ] ----", "SpellSub")
	Menu.SpellSub:addParam("sep", "---- [ ��ʴ��Һ ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("DashesQ", "Ŀ��ͻ��ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellSub:addParam("RangesQ", "Ŀ��ľ���С��", SCRIPT_PARAM_SLICE, 700, 0, SpellQ.Range, -1)
	Menu.SpellSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("sep", "---- [ ������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("DashesE", "Ŀ��ͻ��ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellSub:addParam("RangesE", "Ŀ��ľ���С��", SCRIPT_PARAM_SLICE, 700, 0, SpellE.Range, -1)
	Menu.SpellSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("sep", "---- [ ������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("MinR", "��С��������", SCRIPT_PARAM_SLICE, 500, 0, SpellR.Range, -1)
	Menu.SpellSub:addParam("RStacks1", "һ��������", SCRIPT_PARAM_SLICE, 2, 1, 10, 0)
	Menu.SpellSub:addParam("RStacks2", "����������", SCRIPT_PARAM_SLICE, 3, 1, 10, 0)
	Menu.SpellSub:addParam("RStacks3", "����������", SCRIPT_PARAM_SLICE, 4, 1, 10, 0)

	Menu:addSubMenu("---- [ ��ʾ���� ] ----", "DrawSub")
	Menu.DrawSub:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawW", "��ʾ W ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawR", "��ʾ R ��Χ", SCRIPT_PARAM_ONOFF, false)
end

function KogMawLoad()
	AutoCarry.SkillsCrosshair.range = 1800
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function KogMawCheck()
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

function KogMawCombo(unit)
	if qReady and Menu.ComboSub.ComboQ and GetDistance(unit) < Menu.SpellSub.RangesQ then
		CastVPredQ(unit)
	end
	if wReady and Menu.ComboSub.ComboW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.ComboSub.ComboE and GetDistance(unit) < Menu.SpellSub.RangesE then
		CastVPredE(unit)
	end
	if rReady and Menu.ComboSub.ComboR and GetDistance(unit) > Menu.SpellSub.MinR and GetDistance(unit) < SpellR.Range and StacksCheck() then
		CastVPredR(unit)
	end
end

function KogMawHarass(unit)
	if qReady and Menu.HarassSub.HarassQ and GetDistance(unit) < Menu.SpellSub.RangesQ then
		CastVPredQ(unit)
	end
	if wReady and Menu.HarassSub.HarassW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.HarassSub.HarassE and GetDistance(unit) < Menu.SpellSub.RangesE then
		CastVPredE(unit)
	end
	if rReady and Menu.HarassSub.HarassR and GetDistance(unit) > Menu.SpellSub.MinR and GetDistance(unit) < SpellR.Range and StacksCheck() then
		CastVPredR(unit)
	end
end

function KogMawKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillSub.KillQ and GetDistance(enemy) < SpellQ.Range and qDmg > enemy.health then
				CastVPredQ(enemy)
			elseif Menu.KillSub.KillE and GetDistance(enemy) < SpellE.Range and eDmg > enemy.health then
				CastVPredE(enemy)
			elseif Menu.KillSub.KillR and GetDistance(enemy) < SpellR.Range and rDmg > enemy.health then
				CastVPredR(enemy)
			end
		end
	end
end

function KogMawDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.SpellSub.DashesQ then
				local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
				if IsDashing and CanHit and qReady and GetDistance(Position) < Menu.SpellSub.RangesQ then
					CastSpell(_Q, Position.x, Position.z)
				end
			elseif Menu.SpellSub.DashesE then
				local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
				if IsDashing and CanHit and eReady and GetDistance(Position) < Menu.SpellSub.RangesE then
					CastSpell(_E, Position.x, Position.z)
				end
			end
		end
	end
end

function StacksReset()
	if GetTickCount() > RTimes + 6500 then 
		RStacks = 0
	end
end

function StacksCheck()
	local rLevel = myHero:GetSpellData(_R).level
	if (rLevel == 1 and RStacks < Menu.SpellSub.RStacks1)
	or (rLevel == 2 and RStacks < Menu.SpellSub.RStacks2)
	or (rLevel == 3 and RStacks < Menu.SpellSub.RStacks3)
	then
		return true
	else
		return false
	end
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredW(unit)
	if wReady and ValidTarget(unit) then
		local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellW.Delay, SpellW.Speed, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil and GetDistance(unit) < SpellW.Range then
			if (GetDistance(PredictedPos) < SpellW.Range + VP:GetHitBox(unit)) or (GetDistance(unit) < SpellW.Range + VP:GetHitBox(unit)) then
				CastSpell(_W)
			end
		end
	end
end

function CastVPredE(unit)
	if eReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellE.Delay, SpellE.Width, SpellE.Range, SpellE.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellE.Range then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredR(unit)
	if rReady and ValidTarget(unit) then
		local PredictedPos, EnemyHit = VP:GetPredictedPos(unit, SpellR.Delay, SpellR.Speed, myHero, false)
		local CastPosition, SkillHit, Position = VP:GetCircularCastPosition(unit, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero, false)
		if SkillHit >= 2 and GetDistance(CastPosition) < SpellR.Range then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		elseif EnemyHit >= 2 and GetDistance(PredictedPos) < SpellR.Range then
			CastSpell(_R, PredictedPos.x, PredictedPos.z)
		end
	end
end