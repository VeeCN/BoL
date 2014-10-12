local Version = 1.0

require "VPrediction"

function PluginOnLoad()
	ZileanLoad()
	ZileanMenu()
end

function PluginOnTick()
	ZileanCheck()
	DamageCalculation()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboQ and GetDistance(Target) < SpellQ.Range then
				CastSpell(_Q, Target)
			end
			if wReady and Menu.ComboW and Menu.ComboQ and GetDistance(Target) < SpellQ.Range then
				CastSpell(_Q, Target)
				CastSpell(_W)
				CastSpell(_Q, Target)
			end
			if eReady and Menu.ComboE then
				if GetDistance(Target) < Menu.CRangesE then
					CastSpell(_E, Target)
				else
					CastSpell(_E, myHero)
				end
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassQ and GetDistance(Target) < SpellQ.Range then
				CastSpell(_Q, Target)
			end
			if wReady and Menu.HarassW and Menu.HarassQ and GetDistance(Target) < SpellQ.Range then
				CastSpell(_Q, Target)
				CastSpell(_W)
				CastSpell(_Q, Target)
			end
			if eReady and Menu.HarassE then
				if GetDistance(Target) < Menu.HRangesE then
					CastSpell(_E, Target)
				else
					CastSpell(_E, myHero)
				end
			end
		end
	end
	if Menu.RunMode then
		if not Menu2.AutoCarry and not Menu2.MixedMode then
			if eReady then
				CastSpell(_E, myHero)
			else
				CastSpell(_W)
			end
		else
			Menu.RunMode = false
		end
	end
	if Menu.SmartUlt then
		ZileanUlt()
	end
	if Menu.DashesE and (Menu2.AutoCarry or Menu2.MixedMode or ZileanHealthLow()) then
		ZileanPush()
	end
	ZileanKill()
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
		end
		if Menu.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.Range, 0xFFFFFF)
		end
		if Menu.DrawR and rReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.Range, 0xFFFFFF)
		end
	end
end

function ZileanMenu()
	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("CRangesE", "�������� E", SCRIPT_PARAM_SLICE, 500, 0, SpellE.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HRangesE", "�������� E", SCRIPT_PARAM_SLICE, 500, 0, SpellE.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("SmartKill", "�������л�ɱ", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RunMode", "׷������ģʽ", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ʱ�ⷢ�� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DashesE", "Ŀ��ͻ��ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesE", "Ŀ��ľ���С��", SCRIPT_PARAM_SLICE, 500, 0, SpellE.Range, -1)
	Menu:addParam("HealthE", "�Լ���Ѫ��С��", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ʱ�⵹�� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("SmartUlt", "����ʹ�ô���", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HealthR", "ʹ��Ѫ������", SCRIPT_PARAM_SLICE, 20, 0, 100, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu:addParam("sep", "---- [ ʹ���б� ] ----", SCRIPT_PARAM_INFO, "")
	for _, ally in ipairs(Alliance) do
		if ally then
			Menu:addParam(ally.charName, ally.charName, SCRIPT_PARAM_ONOFF, true)
		else
			Menu:addParam("sep", "û����Ҫʹ�õ��ѷ�Ӣ��", SCRIPT_PARAM_INFO, "")
		end
	end

	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	Menu:addParam("sep", "---- [ ��ʾ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "��ʾ R ��Χ", SCRIPT_PARAM_ONOFF, false)
	
	Menu:permaShow("RunMode")
end

function ZileanLoad()
	AutoCarry.SkillsCrosshair.range = 900
	SpellQ = {Range =  700, Speed = 1100, Delay =  0.5, Width =   0}
	SpellW = {Range =    0, Speed =   20, Delay = 0.25, Width =   0}
	SpellE = {Range =  700, Speed =   20, Delay =  0.2, Width =   0}
	SpellR = {Range =  900, Speed =   20, Delay = 0.25, Width =   0}
	qReady, wReady, eReady, rReady = false, false, false, false
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	Alliance = GetAllyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function ZileanCheck()
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

function ZileanKill()
	if Menu.SmartKill then
		for _, enemy in ipairs(Enemies) do
			if not enemy.dead and ValidTarget(enemy) then
				if GetDistance(enemy) < SpellQ.Range then
					if qDmg > enemy.health then
						CastSpell(_Q, enemy)
					elseif (qDmg * 2) > enemy.health then
						CastSpell(_Q, enemy)
						CastSpell(_W)
						CastSpell(_Q, enemy)
					end
				elseif GetDistance(enemy) > SpellQ.Range and GetDistance(enemy) < 900 then
					if qDmg > enemy.health then
						CastSpell(_E, myHero)
						CastSpell(_Q, enemy)
					elseif (qDmg * 2) > enemy.health then
						CastSpell(_E, myHero)
						CastSpell(_Q, enemy)
						CastSpell(_W)
						CastSpell(_Q, enemy)
					end
				end
			end
		end
	end
end

function ZileanPush()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
			if IsDashing and CanHit and eReady and GetDistance(enemy) < Menu.RangesE then
				CastSpell(_E, enemy)
			end
		end
	end
end

function ZileanUlt()
	local UltTarget = nil
	if (myHero.health / myHero.maxHealth) < (Menu.HealthR / 100) and CountEnemies(900, myHero) > 0 then
		UltTarget = myHero
	end
	for _, ally in ipairs(Alliance) do
		if Menu[ally.charName] and (ally.health / ally.maxHealth) < (Menu.HealthR / 100) and CountEnemies(900, ally) > 0 and GetDistance(ally) < SpellR.Range then
			if not UltTarget or UltTarget.health > ally.health then
				UltTarget = ally
			end
		end
	end
	if UltTarget and rReady then
		CastSpell(_R, UltTarget)
	end
end

function ZileanHealthLow()
	if (myHero.health / myHero.maxHealth) < (Menu.HealthE / 100) then
		return true
	else
		return false
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