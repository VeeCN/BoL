local Version = "1.0"

require "VPrediction"

local SpellQ = {Range = 1300, Speed = 2200, Delay = 1.00, Width =  68}
local SpellW = {Range =  800, Speed = 1450, Delay = 0.25, Width =  51}
local SpellE = {Range =  950, Speed = 2000, Delay = 0.25, Width =  60}
local SpellR = {Range = 3000, Speed = 1500, Delay = 0.38, Width =   0}
local qReady, wReady, eReady, rReady = false, false, false, false

function PluginOnLoad()
	CaitlynLoad()
	CaitlynMenu()
end

function PluginOnTick()
	CaitlynCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			CaitlynCombo(Target)
		end
		if (Menu2.MixedMode or Menu2.LaneClear) and not CaitlynManaLow() then
			CaitlynHarass(Target)
		end
	end
	if Menu.SpellSub.DashesW or Menu.SpellSub.DashesE then
		CaitlynDashes()
	end
	if Menu.SpellSub.ImmobileW then
		CaitlynImmobile()
	end
	if Menu.SpellSub.FastE then
		CaitlynFastE()
	end
	CaitlynKill()
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

function CaitlynMenu()
	Menu:addSubMenu("---- [ �������� ] ----", "ComboSub")
	Menu.ComboSub:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ �������� ] ----", "HarassSub")
	Menu.HarassSub:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("HarassMana", "���Ĺ��� %", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)

	Menu:addSubMenu("---- [ ��ɱ���� ] ----", "KillSub")
	Menu.KillSub:addParam("KillQ", "��ɱʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu.KillSub:addParam("KillR", "��ɱʹ�� R", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ �������� ] ----", "SpellSub")
	Menu.SpellSub:addParam("sep", "---- [ ��ƽʹ�� ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("MinQ", "ʹ�õ���С����", SCRIPT_PARAM_SLICE, 600, 0, SpellQ.Range, -1)
	Menu.SpellSub:addParam("ComboQC", "����ģʽ���С��", SCRIPT_PARAM_ONOFF, false)
	Menu.SpellSub:addParam("HarassQC", "����ģʽ���С��", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellSub:addParam("sep", "---- [ Լ�¶��ղ��� ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("DashesW", "Ŀ��ͻ��ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellSub:addParam("ImmobileW", "Ŀ�����ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellSub:addParam("sep", "---- [ 90�ھ����� ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("DashesE", "Ŀ��ͻ��ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellSub:addParam("MaxE", "ʹ�õ���С����", SCRIPT_PARAM_SLICE, 250, 0, SpellE.Range, -1)
	Menu.SpellSub:addParam("RangesE", "ͻ������С����", SCRIPT_PARAM_SLICE, 600, 0, SpellE.Range, -1)
	Menu.SpellSub:addParam("FastE", "������귽��ͻ��", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	Menu.SpellSub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellSub:addParam("sep", "---- [ ���ӵ��� ] ----", SCRIPT_PARAM_INFO, "")
	Menu.SpellSub:addParam("MinR", "ʹ�õ���С����", SCRIPT_PARAM_SLICE, 600, 0, SpellR.Range, -1)

	Menu:addSubMenu("---- [ ��ʾ���� ] ----", "DrawSub")
	Menu.DrawSub:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawW", "��ʾ W ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawR", "��ʾ R ��Χ", SCRIPT_PARAM_ONOFF, false)
end

function CaitlynLoad()
	AutoCarry.SkillsCrosshair.range = 3000
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function CaitlynCheck()
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

function CaitlynCombo(unit)
	if qReady and Menu.ComboSub.ComboQ and GetDistance(unit) < SpellQ.Range then
		if Menu.SpellSub.ComboQC then
			CastVPredQCollision(unit)
		else
			CastVPredQNoCollision(unit)
		end
	end
	if wReady and Menu.ComboSub.ComboW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.ComboSub.ComboE and GetDistance(unit) < Menu.SpellSub.MaxE then
		CastVPredE(unit)
	end
end

function CaitlynHarass(unit)
	if qReady and Menu.HarassSub.HarassQ and GetDistance(unit) < SpellQ.Range then
		if Menu.SpellSub.HarassQC then
			CastVPredQCollision(unit)
		else
			CastVPredQNoCollision(unit)
		end
	end
	if wReady and Menu.HarassSub.HarassW and GetDistance(unit) < SpellW.Range then
		CastVPredW(unit)
	end
	if eReady and Menu.HarassSub.HarassE and GetDistance(unit) < Menu.SpellSub.MaxE then
		CastVPredE(unit)
	end
end

function CaitlynKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillSub.KillQ and GetDistance(enemy) < SpellQ.Range and qDmg > enemy.health then
				CastVPredQNoCollision(enemy)
			elseif Menu.KillSub.KillR and GetDistance(enemy) < SpellR.Range and rDmg > enemy.health then
				CastVPredR(enemy)
			end
		end
	end
end

function CaitlynDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.SpellSub.DashesE then
				local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
				if IsDashing and CanHit and eReady and GetDistance(Position) < Menu.SpellSub.RangesE then
					CastSpell(_E, Position.x, Position.z)
				end
			elseif Menu.SpellSub.DashesW then
				local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
				if IsDashing and CanHit and wReady and GetDistance(Position) < SpellW.Range then
					CastSpell(_W, Position.x, Position.z)
				end
			end
		end
	end
end

function CaitlynImmobile()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsImmobile, Pos = VP:IsImmobile(enemy, SpellW.Delay, SpellW.Width, SpellW.Speed, myHero)
			if IsImmobile and wReady and GetDistance(Pos) < SpellW.Range then
				CastSpell(_W, Pos.x, Pos.z)
			end
		end
	end
end

function CaitlynFastE()
	if eReady then
		MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
		HeroPos = Vector(myHero.x, myHero.y, myHero.z)
		DashPos = HeroPos + (HeroPos - MPos) * (500 / GetDistance(mousePos))
		myHero:MoveTo(mousePos.x, mousePos.z)
		CastSpell(_E,DashPos.x, DashPos.z)
	end
end

function CaitlynManaLow()
	if (myHero.mana / myHero.maxMana) < (Menu.HarassSub.HarassMana / 100) then
		return true
	else
		return false
	end
end

function CastVPredQCollision(unit)
	if qReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(PredictedPos) > Menu.SpellSub.MinQ and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end
function CastVPredQNoCollision(unit)
	if qReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(PredictedPos) > Menu.SpellSub.MinQ and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredW(unit)
	if wReady and ValidTarget(unit) then
		local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellW.Delay, SpellW.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(PredictedPos) < SpellW.Range then
			CastSpell(_W, PredictedPos.x, PredictedPos.z)
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
		local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellR.Delay, SpellR.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(PredictedPos) > Menu.SpellSub.MinR and GetDistance(PredictedPos) < SpellR.Range then
			CastSpell(_R, unit)
		end
	end
end