--Barianification
local s,id=GetID()
function s.initial_effect(c)
	--Skill setup (once per duel, standard flip)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
--Flip at the start of the duel
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil) and Duel.GetFlagEffect(tp,id)<3
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.GetFlagEffect(tp,id)>=3 then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	for tc in aux.Next(g) do
		local code=tc:GetOriginalCode()
		e:SetLabel(code)
		Duel.SendtoDeck(tc,nil,-2,REASON_EFFECT+REASON_RULE)
		local token=Duel.CreateToken(tp,code)
		local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		if opt==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummonStep(token,0,tp,tp,true,false,tc:GetPosition())
			Duel.SpecialSummonComplete()
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(token,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,token)
		end
	end
end
--Filter for cards in either GY
function s.filter(c)
	return c:IsAbleToRemove() and c:IsReason(REASON_BATTLE+REASON_DESTROY)
end