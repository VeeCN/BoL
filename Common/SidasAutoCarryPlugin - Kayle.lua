local Version = 1.0

require "VPrediction"

local SpellQ = {Range =  650, Speed = 1500, Delay = 0.25, Width =   0}
local SpellW = {Range =  900, Speed =   20, Delay = 0.39, Width =   0}
local SpellE = {Range =  525, Speed =  780, Delay = 0.25, Width =   0}
local SpellR = {Range =  900, Speed =    0, Delay = 0.25, Width =   0}
local qReady, wReady, eReady, rReady = false, false, false, false

function PluginOnLoad()
	KayleLoad()
	KayleMenu()
end

function PluginOnTick()
	KayleCheck()
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			KayleCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			KayleHarass(Target)
		end
	end
	if Menu.SmartUlt then
		KayleUlt()
	end
	if Menu.DashesQ then
		KayleDashes()
	end
	KayleKill()
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

function KayleMenu()
	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ComboQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("ComboE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu:addParam("sep", "---- [ �������� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("HarassQ", "����ʹ�� Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassW", "����ʹ�� W", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("HarassE", "����ʹ�� E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("sep", "---- [ ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("SmartKill", "�������л�ɱ", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("DashesQ", "Ŀ��ͻ��ʱʹ��", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("RangesQ", "ʹ�õľ�������", SCRIPT_PARAM_SLICE, 500, 0, SpellQ.Range, -1)
	Menu:addParam("sep", "", SCRIPT_PARAM_INFO, "")
	
	Menu:addParam("sep", "---- [ ��ʥ�ӻ� ] ----", SCRIPT_PARAM_INFO, "")
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
	Menu:addParam("sep1", "---- [ ��ʾ���� ] ----", SCRIPT_PARAM_INFO, "")
	Menu:addParam("DrawQ", "��ʾ Q ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawW", "��ʾ W ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawE", "��ʾ E ��Χ", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawR", "��ʾ R ��Χ", SCRIPT_PARAM_ONOFF, false)
end

function KayleLoad()
	AutoCarry.SkillsCrosshair.range = 900
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Enemies = GetEnemyHeroes()
	Alliance = GetAllyHeroes()
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
end

function KayleCheck()
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

function KayleCombo(unit)
	if qReady and Menu.ComboQ and GetDistance(unit) < SpellQ.Range then
		CastSpell(_Q, unit)
	end
	if wReady and Menu.ComboW and GetDistance(unit) > SpellE.Range then
		CastSpell(_W)
	end
	if eReady and Menu.ComboE and GetDistance(unit) < SpellE.Range then
		CastSpell(_E)
	end
end

function KayleHarass(unit)
	if qReady and Menu.HarassQ and GetDistance(unit) < SpellQ.Range then
		CastSpell(_Q, unit)
	end
	if wReady and Menu.HarassW and GetDistance(unit) > SpellE.Range then
		CastSpell(_W)
	end
	if eReady and Menu.HarassE and GetDistance(unit) < SpellE.Range then
		CastSpell(_E)
	end
end

function KayleKill()
	if Menu.SmartKill then
		for _, enemy in ipairs(Enemies) do
			if not enemy.dead and ValidTarget(enemy) then
				if qDmg > enemy.health then
					if GetDistance(enemy) > SpellQ.Range and GetDistance(enemy) < 900 then
						CastSpell(_W)
						CastSpell(_Q, enemy)
					elseif GetDistance(enemy) < SpellQ.Range then
						CastSpell(_Q, enemy)
					end
				end
			end
		end
	end
end

function KayleDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) and GetDistance(enemy) < SpellQ.Range then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellQ.Delay, SpellQ.Width, SpellQ.Speed, myHero)
			if IsDashing and CanHit and qReady and GetDistance(Position) < Menu.RangesQ then
				CastSpell(_Q, enemy)
			end
		end
	end
end

function KayleUlt()
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

function CountEnemies(range, unit)
    local enemys = 0
    for _, enemy in ipairs(Enemies) do
        if ValidTarget(enemy) and not enemy.dead and GetDistance(enemy, unit) < (range or math.huge) then
            enemys = enemys + 1
        end
    end
    return enemys
end