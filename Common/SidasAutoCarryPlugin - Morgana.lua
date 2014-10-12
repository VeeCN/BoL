require 'VPrediction'

function PluginOnLoad()
	MorganaLoad()
	MorganaMenu()
end

function PluginOnTick()
	MorganaCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboQ and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if wReady and Menu.ComboW and GetDistance(Target) < SpellW.Range then
				CastVPredW(Target)
			end
			if rReady and Menu.ComboR and GetDistance(Target) < SpellR.Range and CountEnemyHeroInRange(SpellR.Range) >= Menu.EnemiesR then
				CastSpell(_R)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassQ and GetDistance(Target) < SpellQ.Range then
				CastVPredQ(Target)
			end
			if wReady and Menu.HarassW and GetDistance(Target) < SpellW.Range then
				CastVPredW(Target)
			end
			if rReady and Menu.HarassR and GetDistance(Target) < SpellR.Range and CountEnemyHeroInRange(SpellR.Range) >= Menu.EnemiesR then
				CastSpell(_R)
			end
		end
	end
	if Menu.DashesQ and (Menu2.AutoCarry or MorganaHealthLow()) then
		MorganaDashes()
	end
	if (Menu.ImmobileQ or Menu.ImmobileW) and (Menu2.AutoCarry or MorganaHealthLow()) then
		MorganaImmobile()
	end
	MorganaKill()
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFF000000)
		end
		if Menu.DrawW and wReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.Range, 0xFF000000)
		end
		if Menu.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.Range, 0xFF000000)
		end
		if Menu.DrawR and rReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.Range, 0xFF000000)
		end
	end
end

function MorganaMenu()
	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboR", "����ʹ�� R", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassR", "����ʹ�� R", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("EnemiesR", "�������� R", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("KillQ", "��ɱʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KillW", "��ɱʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��֮���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ImmobileQ", "Ŀ�����ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("DashesQ", "Ŀ��ͻ��ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesQ", "Ŀ��ľ���С��", SCRIPT_PARAM_SLICE, 600, 0, 1170, -1)
	Menu:addParam("HealthQ", "�Լ���Ѫ��С��", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ʹ�ฯʴ ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ImmobileW", "Ŀ�����ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��ʾ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "��ʾ W ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "��ʾ R ��Χ", SCRIPT_PARAM_ONOFF, false)
end

function MorganaLoad()
	AutoCarry.SkillsCrosshair.range = 1175
	SpellQ = {Range = 1175, Speed = 1200, Delay = 0.25, Width =  70}
	SpellW = {Range =  900, Speed =   20, Delay = 0.25, Width = 175}
	SpellE = {Range =  750, Speed =   20, Delay = 0.52, Width =   0}
	SpellR = {Range =  600, Speed =   20, Delay = 0.35, Width =   0}
	qReady, wReady, eReady, rReady = false, false, false, false
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function MorganaCheck()
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

function MorganaKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillQ and GetDistance(enemy) < SpellQ.Range and qDmg > enemy.health then
				CastVPredQ(enemy)
			elseif Menu.KillW and GetDistance(enemy) < SpellW.Range and wDmg > enemy.health then
				CastVPredW(enemy)
			end
		end
	end
end

function MorganaDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
			if IsDashing and CanHit and qReady and GetDistance(Position) < Menu.RangesQ then
				CastSpell(_Q, Position.x, Position.z)
			end
		end
	end
end

function MorganaImmobile()
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
					CastSpell(_W, Pos.x, Pos.z)
				end
			end
		end
	end
end

function MorganaHealthLow()
	if (myHero.health / myHero.maxHealth) < (Menu.HealthQ / 100) then
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
		local CastPosition, HitChance, Position = VP:GetCircularCastPosition(unit, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellW.Range then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end