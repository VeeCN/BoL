local Version = 1.0

require "VPrediction"

function PluginOnLoad()
	CorkiLoad()
	CorkiMenu()
end

function PluginOnTick()
	CorkiCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboQ and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if eReady and Menu.ComboE and GetDistance(Target) < SpellE.Range then
				CastSpell(_E, Target)
			end
			if rReady and Menu.ComboR and GetDistance(Target) < SpellR.Range then
				CastVPredR(Target)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassQ and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if eReady and Menu.HarassE and GetDistance(Target) < SpellE.Range then
				CastSpell(_E, Target)
			end
			if rReady and Menu.HarassR and GetDistance(Target) < SpellR.Range then
				CastVPredR(Target)
			end
		end
	end
	CorkiKill()
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
		end
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

function CorkiMenu()
	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboR", "����ʹ�� R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassR", "����ʹ�� R", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��ɱ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillQ", "��ɱʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillR", "��ɱʹ�� R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��ʾ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "��ʾ W ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "��ʾ R ��Χ", SCRIPT_PARAM_ONOFF, false)
end

function CorkiLoad()
	AutoCarry.SkillsCrosshair.range = 1225
	SpellQ = {Range =  825, Speed =  850, Delay = 0.25, Width = 250}
	SpellW = {Range =  800, Speed =  700, Delay = 0.50, Width = 160}
	SpellE = {Range =  600, Speed =  902, Delay = 0.25, Width = 100}
	SpellR = {Range = 1225, Speed =  829, Delay = 0.18, Width =  40}
	qReady, wReady, eReady, rReady = false, false, false, false
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function CorkiCheck()
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

function CorkiKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillQ and GetDistance(enemy) < SpellQ.Range and qDmg > enemy.health then
				CastVPredQ(enemy)
			elseif Menu.KillR and GetDistance(enemy) < SpellR.Range and rDmg > enemy.health then
				CastVPredR(enemy)
			end
		end
	end
end

function CastVPredQ(unit)
	if qReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetCircularCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastVPredR(unit)
	if rReady and ValidTarget(unit) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellR.Range then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end