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
	Menu:addParam("sep", "---- [ 连招设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 消耗设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 宗师之威 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("UseR", "智能使用大招", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("UseREnemies", "使用最小人数", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("UseRHealths", "使用最小血量", SCRIPT_PARAM_SLICE, 80, 0, 100, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 其他设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("UseEQ", "使用 E + Q 连招", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
	Menu:addParam("SmartKill", "智能连招击杀", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ 显示设置 ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "显示 Q 范围", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)

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