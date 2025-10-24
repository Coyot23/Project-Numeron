--Infernal Countermeasure
local s,id=GetID()
function s.initial_effect(c)
	aux.AddFieldSkillProcedure(c,2,false)
	-- allow this card to hold chaos counters
	c:EnableCounterPermit(0x13)
	s.groupX={511001431,93300002}
	--Place 1 counter when the duel starts
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetCountLimit(1)
	e0:SetRange(LOCATION_FZONE)
	e0:SetOperation(s.startop)
	c:RegisterEffect(e0)
	--Burn during each Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(s.burnop)
	c:RegisterEffect(e1)
	--Cannot be targeted or destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- utility: check if a player controls any card from Group X
local function controlsGroupX(tp)
	for _,code in ipairs(s.groupX) do
		if Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(code) end,
			tp,LOCATION_ONFIELD,0,1,nil) then
			return true
		end
	end
	return false
end
--When duel begins: add 1 counter
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetTurnCount()==1 and c:GetCounter(0x13)==0 then
		c:AddCounter(0x13,1)
	end
end
--Each Standby Phase: burn then add another counter
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsRelateToEffect(e) then return end
	local count=c:GetCounter(0x13)
	local p=Duel.GetTurnPlayer()
	--Skip damage if the turn player controls a Group X card
	if not controlsGroupX(p) and count>0 then
		Duel.Damage(p,count*500,REASON_EFFECT)
	end
	c:AddCounter(0x13,1)
end