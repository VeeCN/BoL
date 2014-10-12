local Version = 1.0

function PluginOnLoad()
	JaxLoad()
	JaxMenu()
end

function PluginOnTick()
	JaxCheck()
	if ValidTarget(Target) then
		if Menu.UseEQ and (Menu2.AutoCarry or Menu2.MixedMode or Menu2.LaneClear) then
			if GetDistance(Target) < qRange then
				if CounterStrike == false and eReady and qReady then
					CastSpell(_E)
				end
				if CounterStrike == true and qReady then
					CastSpell(_Q, Target)
				end
				if CounterStrike == true and GetDistance(Target) < eRange then
					CastSpell(_E)
				end
				Menu.UseEQ = false
			end
		end
		if Menu.UseR and (Menu2.AutoCarry or Menu2.MixedMode or Menu2.LaneClear) then
			if CountEnemyHeroInRange(qRange) >= Menu.UseREnemies or (myHero.health / myHero.maxHealth) < (Menu.UseRHealths / 100) then
				CastSpell(_R)
			end
		end
		if Menu2.AutoCarry then
			if Menu.ComboQ and GetDistance(Target) < qRange then
				CastSpell(_Q, Target)
			end
			if Menu.ComboW and GetDistance(Target) < 375 then
				CastSpell(_W)
			end
			if Menu.ComboE and GetDistance(Target) < eRange then
				CastSpell(_E)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if Menu.HarassQ and GetDistance(Target) < qRange then
				CastSpell(_Q, Target)
			end
			if Menu.HarassW and GetDistance(Target) < 375 then
				CastSpell(_W)
			end
			if Menu.HarassE and GetDistance(Target) < eRange then
				CastSpell(_E)
			end
		end
	end
	JaxKill()
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x7F006E)
		end
		if Menu.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x490041)
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == 'JaxCounterStrike' then
		CounterStrike = true
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == 'JaxCounterStrike' then
		CounterStrike = false
	end
end

function JaxMenu()
	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��ʦ֮�� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("UseR", "����ʹ�ô���", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("UseREnemies", "ʹ����С����", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("UseRHealths", "ʹ����СѪ��", SCRIPT_PARAM_SLICE, 80, 0, 100, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("UseEQ", "ʹ�� E + Q ����", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
	Menu:addParam("SmartKill", "�������л�ɱ", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��ʾ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)

	Menu:permaShow("UseEQ")
end

function JaxLoad()
	AutoCarry.SkillsCrosshair.range = 700
	qRange, eRange = 700, 187.5
	qReady, wReady, eReady, rReady = false, false, false, false
	CounterStrike = false
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function JaxCheck()
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

function JaxKill()
	if Menu.SmartKill then
		for _, enemy in ipairs(Enemies) do
			if not enemy.dead and ValidTarget(enemy) then
				if GetDistance(enemy) < qRange and qDmg > enemy.health then
					if CountEnemies(375, enemy) > 2 then
						CastSpell(_W)
						CastSpell(_Q, enemy)
						CastSpell(_E)
					else
						CastSpell(_W)
						CastSpell(_Q, enemy)
					end
				end
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