--Chaos Hand
local s,id=GetID()
function s.initial_effect(c)
	--Destroy all, then optionally summon up to 2 specific monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Quick version if you control 2+ other cards
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.qecon2)
	c:RegisterEffect(e2)
end
--if opponent controls more monsters than you
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0) <Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		and not s.qecon(e,tp,eg,ep,ev,re,r,rp)
end
function s.qecon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)	<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		and s.qecon(e,tp,eg,ep,ev,re,r,rp)
end
--quick-effect condition: you already control 2+ other cards besides this
function s.qecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>2
end
--target all cards on field for destruction
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
--destroy all, then optionally summon the hands
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	local summonable=Group.CreateGroup()
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if #g1>0 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg1=g1:Select(tp,1,1,nil)
			summonable:Merge(sg1)
		end
	end
	if #g2>0 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg2=g2:Select(tp,1,1,nil)
			summonable:Merge(sg2)
		end
	end
	if #summonable>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#summonable then
		Duel.SpecialSummon(summonable,0,tp,tp,false,false,POS_FACEUP)
	end
end
s.listed_names={95929069,68535320}
function s.spfilter1(c,e,tp)
	return c:IsCode(95929069) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp)
	return c:IsCode(68535320) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end