local Version = 1.0

function PluginOnLoad()
	MasterYiLoad()
	MasterYiMenu()
end

function PluginOnTick()
	MasterYiCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			if qReady and Menu.ComboQ and GetDistance(Target) < qRange then
				CastSpell(_Q, Target)
			end
			if eReady and Menu.ComboE and GetDistance(Target) < eRange then
				CastSpell(_E)
			end
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			if qReady and Menu.HarassQ and GetDistance(Target) < qRange then
				CastSpell(_Q, Target)
			end
			if eReady and Menu.HarassE and GetDistance(Target) < eRange then
				CastSpell(_E)
			end
		end
	end
	MasterYiKill()
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawQ and qReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFFFF)
		end
		if Menu.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFFFFFF)
		end
	end
end

function MasterYiMenu()
	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��ɱ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KillQ", "��ɱʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ ��ʾ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)
end

function MasterYiLoad()
	AutoCarry.SkillsCrosshair.range = 600
	qRange, eRange = 600, 125
	qReady, wReady, eReady, rReady = false, false, false, false
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function MasterYiCheck()
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

function MasterYiKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillQ and GetDistance(enemy) < qRange and qDmg > enemy.health then
				CastSpell(_Q, enemy)
			end
		end
	end
end