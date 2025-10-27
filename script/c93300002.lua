--Chaos Rose Dragon
--Scripted by TDH Project
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Destroy all + self-revive + destroy again + revive again
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Quick Effect: destroy 1 card, if it survives, banish it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1}) -- hard once per turn, separate from the first effect
	e2:SetTarget(s.qetg)
	e2:SetOperation(s.qeop)
	c:RegisterEffect(e2)
	--During the End Phase: destroy 1 card, if not destroyed, return it to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.endtg)
	e3:SetOperation(s.endop)
	c:RegisterEffect(e3)
end

--Target all cards on the field
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

--Destroy + conditional self-revive + destroy again
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and not c:IsLocation(LOCATION_MZONE)
		and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) then
		--It was destroyed by its own effect → revive it
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) then
			Duel.BreakEffect()
			if Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)~=0 then
				c:CompleteProcedure()
				--After revival, destroy all cards again
				local g2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
				Duel.BreakEffect()
				local ct2=Duel.Destroy(g2,REASON_EFFECT)
				--If destroyed again by its own effect, revive again (final)
				if ct2>0 and not c:IsLocation(LOCATION_MZONE)
					and c:IsPreviousLocation(LOCATION_MZONE)
					and c:IsPreviousControler(tp)
					and c:IsPreviousPosition(POS_FACEUP) then
					if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
						and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) then
						Duel.BreakEffect()
						Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
						c:CompleteProcedure()
					end
				end
			end
		end
	end
end
--Target 1 card to destroy (and maybe banish)
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

--Destroy, and if it’s still there, banish it
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc,REASON_EFFECT)==0 and tc:IsOnField() then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
--last effect
function s.endtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc,REASON_EFFECT)==0 and tc:IsOnField() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end