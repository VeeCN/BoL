local Version = "1.0"

require "VPrediction"

local SpellQ = {Range =  650, Speed =    0, Delay = 0.25, Width =  90}
local SpellW = {Range =  550, Speed =    0, Delay = 0.25, Width =   0}
local SpellE = {Range = 1050, Speed = 1600, Delay = 0.50, Width =  98}
local SpellR = {Range = 4000, Speed = 2000, Delay = 0.50, Width = 120}
local qReady, wReady, eReady, rReady = false, false, false, false
local CurrentMS = myHero.ms
local CurrentAS = myHero.attackSpeed
local qBuff = 0
local qStacks = 0
local MovePoint = nil
local closestReticle = nil
local closestmouseReticle = nil
local reticles = {}
local Draven_Rs = {}
local Interrupt = {}
local InterruptList = {
	{ charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
	{ charName = "FiddleSticks", spellName = "Crowstorm"},
	{ charName = "Galio", spellName = "GalioIdolOfDurand"},
	{ charName = "Karthus", spellName = "FallenOne"},
	{ charName = "Katarina", spellName = "KatarinaR"},
	{ charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
	{ charName = "MissFortune", spellName = "MissFortuneBulletTime"},
	{ charName = "Nunu", spellName = "AbsoluteZero"},
	{ charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
	{ charName = "Shen", spellName = "ShenStandUnited"},
	{ charName = "Urgot", spellName = "UrgotSwap2"},
	{ charName = "Velkoz", spellName = "VelkozR"},
	{ charName = "Warwick", spellName = "InfiniteDuress"},
	{ charName = "TwistedFate", spellName = "gate"},
	{ charName = "Morgana", spellName = "SoulShackles"}
}

function PluginOnLoad()
	DravenLoad()
	DravenMenu()
end

function PluginOnTick()
	DravenCheck()
	if TableLength(reticles) > 0 then
		for _, particle in pairs(reticles) do
			if closestReticle and closestReticle.object.valid and particle.object and particle.object.valid then
				if GetDistance(particle.object) > GetDistance(closestReticle.object) then
					closestReticle = particle
				end
			else
				closestReticle = particle
			end
		end
		for _, particle in pairs(reticles) do
			if closestmouseReticle and closestmouseReticle.object.valid and particle.object and particle.object.valid then
				if GetDistance(particle.object, mousePos) > GetDistance(closestmouseReticle.object, mousePos) then
					closestmouseReticle = particle
				end
			else
				closestmouseReticle = particle
			end
		end
	end
	if Menu2.AutoCarry or Menu2.MixedMode or Menu2.LastHit or Menu2.LaneClear then
		if Menu.SpellQSub.CastMouse and closestmouseReticle ~= nil and closestmouseReticle.object.valid and TableLength(reticles) > 0 then
			if GetDistance(closestmouseReticle.object, mousePos) < Menu.SpellQSub.CastMouseDistance and GetDistance(closestmouseReticle.object, mousePos) < Menu.SpellQSub.CatchOffset then
				Orbwalker:OverrideOrbwalkLocation(nil)
				if Menu.SpellQSub.StopMovement then
					MyHero:MovementEnabled(false)
				end
			elseif GetDistance(closestmouseReticle.object, mousePos) < Menu.SpellQSub.CastMouseDistance and GetDistance(closestmouseReticle.object, mousePos) >= Menu.SpellQSub.CatchOffset then
				Orbwalker:OverrideOrbwalkLocation(Vector(closestmouseReticle.object.x, 0, closestmouseReticle.object.z))
				if Menu.SpellQSub.StopMovement then
					MyHero:MovementEnabled(true)
				end
			end
		else
			if Menu.SpellQSub.StopMovement then
				MyHero:MovementEnabled(true)
			end
			Orbwalker:OverrideOrbwalkLocation(nil)
		end
	else
		if Menu.SpellQSub.StopMovement then
			MyHero:MovementEnabled(true)
		end
		Orbwalker:OverrideOrbwalkLocation(nil)
	end
	if ValidTarget(Target) then
		if Menu2.AutoCarry then
			DravenCombo(Target)
		end
		if Menu2.MixedMode or Menu2.LaneClear then
			DravenHarass(Target)
		end
	end
	if Menu.SpellESub.DashesE then
		DravenDashes()
	end
	DravenKill()
end

function PluginOnProcessSpell(unit, spell)
	if Menu.SpellESub.InterruptE then
		if #Interrupt > 0 then
			for _, Inter in pairs(Interrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if Menu.SpellESub[Inter.spellName] and GetDistance(unit) < SpellE.Range then
						CastVPredE(unit)
					end
				end
			end
		end
	end
end

function PluginOnCreateObj(obj)
	if obj.name == "Draven_Q_buf.troy" then
		qBuff = qBuff + 1
	end
	if obj ~= nil and obj.name ~= nil and obj.x ~= nil and obj.z ~= nil then
		if obj.name:find("reticle_self.troy") then
			table.insert(reticles, {object = obj, created = GetTickCount()})
		elseif obj.name == "draven_spinning_buff_end_sound.troy" then
			qStacks = 0
		elseif obj.name == "Draven_R_cas.troy" and obj.team ~= TEAM_ENEMY then
			table.insert(Draven_Rs, obj)
		end
	end
end

function PluginOnDeleteObj(obj)
	if obj.name:find("reticle_self.troy") then
		if GetDistance(obj) > SpellQ.Width then
			qStacks = qStacks - 1
		end
		for i, reticle in ipairs(reticles) do
			if obj and obj.valid and reticle.object and reticle.object.valid and obj.x == reticle.object.x and obj.z == reticle.object.z then
				table.remove(reticles, i)
				current_tick = GetTickCount()
				tick_difference = current_tick - reticle.created
			end
		end
	elseif obj.name == "Draven_Q_buf.troy" then
		qBuff = qBuff - 1
	elseif obj.name == "Draven_R_cas.troy" then
		for i, Draven_R in ipairs(Draven_Rs) do
			if obj and obj.valid and Draven_R and Draven_R.valid and obj == Draven_R then
				table.remove(Draven_Rs, i)
			end
		end
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if Menu.DrawSub.DrawQ then
			for _, particle in pairs(reticles) do
				Helper:DrawCircleObject(particle.object, SpellQ.Width, ARGB(255, 0, 255, 0), 1)
			end
		end
		if Menu.DrawSub.DrawE and eReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.Range, 0xFFFFFF)
		end
	end
end

function DravenMenu()
	Menu:addSubMenu("---- [ 连招设置 ] ----", "ComboSub")
	Menu.ComboSub:addParam("ComboQ", "连招使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboW", "连招使用 W", SCRIPT_PARAM_ONOFF, true)
	Menu.ComboSub:addParam("ComboE", "连招使用 E", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ 消耗设置 ] ----", "HarassSub")
	Menu.HarassSub:addParam("HarassQ", "消耗使用 Q", SCRIPT_PARAM_ONOFF, true)
	Menu.HarassSub:addParam("HarassW", "消耗使用 W", SCRIPT_PARAM_ONOFF, false)
	Menu.HarassSub:addParam("HarassE", "消耗使用 E", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("---- [ 击杀设置 ] ----", "KillSub")
	Menu.KillSub:addParam("KillE", "击杀使用 E", SCRIPT_PARAM_ONOFF, true)
	Menu.KillSub:addParam("KillR", "击杀使用 R", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("---- [ 旋转飞斧 ] ----", "SpellQSub")
	Menu.SpellQSub:addParam("ThreeQ", "使用三层飞斧", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellQSub:addParam("FourQ", "使用四层飞斧", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellQSub:addParam("CastMouse", "使用鼠标位置", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellQSub:addParam("CastMouseDistance", "落点鼠标距离", SCRIPT_PARAM_SLICE, 100, 50, 150, -1)
	Menu.SpellQSub:addParam("CatchOffset", "准星鼠标距离", SCRIPT_PARAM_SLICE, 60, 50, 150, -1)
	Menu.SpellQSub:addParam("StopMovement", "落点停止移动", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("---- [ 血性冲刺 ] ----", "SpellWSub")
	Menu.SpellWSub:addParam("MaxW", "使用的最大距离", SCRIPT_PARAM_SLICE, 300, 0, 1050, -1)

	Menu:addSubMenu("---- [ 开道利斧 ] ----", "SpellESub")
	Menu.SpellESub:addParam("MaxE", "使用的最大距离", SCRIPT_PARAM_SLICE, 300, 0, SpellE.Range, -1)
	Menu.SpellESub:addParam("DashesE", "目标突进时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellESub:addParam("RangesE", "突进的距离小于", SCRIPT_PARAM_SLICE, 600, 0, SpellE.Range, -1)
	Menu.SpellESub:addParam("InterruptE", "目标大招时使用", SCRIPT_PARAM_ONOFF, true)
	Menu.SpellESub:addParam("sep", "", SCRIPT_PARAM_INFO, "")

	Menu.SpellESub:addParam("sep", "---- [ 打断列表 ] ----", SCRIPT_PARAM_INFO, "")
	if #Interrupt > 0 then
		for _, Inter in pairs(Interrupt) do
			Menu.SpellESub:addParam(Inter.spellName, Inter.charName.." → "..Inter.spellName, SCRIPT_PARAM_ONOFF, true)
		end
	else
		Menu.SpellESub:addParam("sep", "没有需要打断的英雄技能", SCRIPT_PARAM_INFO, "")
	end

	Menu:addSubMenu("---- [ 冷血追命 ] ----", "SpellRSub")
	Menu.SpellRSub:addParam("MinR", "使用的最小距离", SCRIPT_PARAM_SLICE, 600, 0, SpellR.Range, -1)
	Menu.SpellRSub:addParam("MaxR", "使用的最大距离", SCRIPT_PARAM_SLICE, 2000, 0, SpellR.Range, -1)

	Menu:addSubMenu("---- [ 显示设置 ] ----", "DrawSub")
	Menu.DrawSub:addParam("DrawQ", "显示 Q 落点", SCRIPT_PARAM_ONOFF, false)
	Menu.DrawSub:addParam("DrawE", "显示 E 范围", SCRIPT_PARAM_ONOFF, false)
end

function DravenLoad()
	AutoCarry.SkillsCrosshair.range = 4000
	VP = VPrediction()
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	Helper = AutoCarry.Helper
	Enemies = GetEnemyHeroes()
	Orbwalker = AutoCarry.Orbwalker
	CurrentMS = myHero.ms
	CurrentAS = 0.679 * myHero.attackSpeed
	if AutoCarry.Skills then
		AutoCarry.Skills:DisableAll()
	end
	if qStacks < qBuff then
		qStacks = qBuff
	end
	if qStacks > qBuff + TableLength(reticles) then
		qStacks = qBuff + TableLength(reticles)
	end
	for _, enemy in pairs(Enemies) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				table.insert(Interrupt, {charName = champ.charName, spellName = champ.spellName})
			end
		end
	end
end

function DravenCheck()
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

function DravenCombo(unit)
	if qReady and Menu.ComboSub.ComboQ and GetDistance(unit) < 1050 then
		CastVPredQ(unit)
	end
	if eReady and Menu.ComboSub.ComboW and GetDistance(unit) < 1050 then
		CastVPredW(unit)
	end
	if rReady and Menu.ComboSub.ComboE and ((GetDistance(unit) < Menu.SpellESub.MaxE) or (GetDistance(unit) > SpellE.Range and GetDistance(unit) < 1050)) then
		CastVPredE(unit)
	end
end

function DravenHarass(unit)
	if qReady and Menu.HarassSub.HarassQ and GetDistance(unit) < 1050 then
		CastVPredQ(unit)
	end
	if eReady and Menu.HarassSub.HarassW and GetDistance(unit) < 1050 then
		CastVPredW(unit)
	end
	if rReady and Menu.HarassSub.HarassE and ((GetDistance(unit) < Menu.SpellESub.MaxE) or (GetDistance(unit) > SpellE.Range and GetDistance(unit) < 1050)) then
		CastVPredE(unit)
	end
end

function DravenKill()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			if Menu.KillSub.KillE and GetDistance(enemy) < SpellE.Range and eDmg > enemy.health then
				CastVPredE(enemy)
			elseif Menu.KillSub.KillR and GetDistance(enemy) < SpellR.Range and rDmg > enemy.health then
				CastVPredR(enemy)
			end
		end
	end
end

function DravenDashes()
	for _, enemy in ipairs(Enemies) do
		if not enemy.dead and ValidTarget(enemy) then
			local IsDashing, CanHit, Position = VP:IsDashing(enemy, SpellE.Delay, SpellE.Width, SpellE.Speed, myHero)
			if IsDashing and CanHit and eReady and GetDistance(Position) < Menu.SpellESub.RangesE then
				CastVPredE(enemy)
			end
		end
	end
end

function TableLength(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function CastVPredQ(unit)
	local numQs = qBuff + TableLength(reticles)
	if qReady and ValidTarget(unit) then
		local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellQ.Delay, SpellQ.Speed, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil and GetDistance(unit) < 1050 then
			if (GetDistance(PredictedPos) < SpellQ.Range + VP:GetHitBox(unit)) or (GetDistance(unit) < SpellQ.Range + VP:GetHitBox(unit)) then
				if numQs < 2 and not Menu.SpellQSub.ThreeQ and not Menu.SpellQSub.FourQ then
					CastSpell(_Q)
				elseif numQs < 3 and Menu.SpellQSub.ThreeQ and not Menu.SpellQSub.FourQ then
					CastSpell(_Q)
				elseif numQs < 4 and Menu.SpellQSub.FourQ then
					CastSpell(_Q)
				end
			end
		end
	end
end

function CastVPredW(unit)
	if wReady and ValidTarget(unit) then
		local PredictedPos, HitChance = VP:GetPredictedPos(unit, SpellW.Delay, SpellW.Speed, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil and GetDistance(unit) < 1050 then
			if (GetDistance(PredictedPos) > SpellW.Range + VP:GetHitBox(unit)) or (GetDistance(unit) > SpellW.Range + VP:GetHitBox(unit)) then
				CastSpell(_W)
			elseif (GetDistance(PredictedPos) < Menu.SpellWSub.MaxW + VP:GetHitBox(unit)) or (GetDistance(unit) < Menu.SpellWSub.MaxW + VP:GetHitBox(unit)) then
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
		local CastPosition, SkillHit, Position = VP:GetLineCastPosition(unit, SpellR.Delay, SpellR.Width, Menu.MaxR, SpellR.Speed, myHero, false)
		if EnemyHit >= 2 and GetDistance(PredictedPos) > Menu.SpellRSub.MinR and GetDistance(PredictedPos) < Menu.SpellRSub.MaxR then
			CastSpell(_R, PredictedPos.x, PredictedPos.z)
		elseif SkillHit >= 2 and GetDistance(CastPosition) > Menu.SpellRSub.MinR and GetDistance(CastPosition) < Menu.SpellRSub.MaxR then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end