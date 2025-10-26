--The Tides of Battle!
local s,id=GetID()
local COUNTER_CAULDRON=COUNTER_FOG
function s.initial_effect(c)
	--synchro summon
	c:AddMustBeSpecialSummoned()
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e1)
	--Set in F.Zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,5))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTarget(s.fztg)
	e6:SetOperation(s.fzop)	
	c:RegisterEffect(e6)
	--Place counters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--inflict damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.cost)
	e3:SetTarget(s.dmgtg)
	e3:SetOperation(s.dmgop)
	c:RegisterEffect(e3)
	--Add any card from deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--Set your LP
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCountLimit(1)
	e5:SetOperation(s.lpop)
	c:RegisterEffect(e5)
	--set opp lp
	local e6=e5:Clone()
	e6:SetDescription(aux.Stringid(id,6))
	e6:SetOperation(s.lpop2)
	c:RegisterEffect(e6)
end
--Set itself
function s.fztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)<2 end
end
function s.fzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
--		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_PHASE_END&~(RESET_TOFIELD|RESET_TURN_SET),0,1)
	end
end
--no idea what this does
function s.filter(c)
	return c:GetCounter(COUNTER_FOG)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	local s=0
	for tc in aux.Next(g) do
		local ct=tc:GetCounter(COUNTER_FOG)
		s=s+ct
		tc:RemoveCounter(tp,COUNTER_FOG,ct,REASON_COST)
	end
	e:SetLabel(s*100)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
--function to place an arbitrary amount of counters
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local one=Duel.AnnounceNumberRange(tp,0,9)
	local ten=Duel.AnnounceNumberRange(tp,0,9)
	local hundred=Duel.AnnounceNumberRange(tp,0,9)
	local thousand=Duel.AnnounceNumberRange(tp,0,100)
	if c:IsRelateToEffect(e) then
		c:AddCounter(COUNTER_CAULDRON,one+ten*10+hundred*100+thousand*1000)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
--setting your LP
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local one=Duel.AnnounceNumberRange(tp,0,9)
	local ten=Duel.AnnounceNumberRange(tp,0,9)
	local hundred=Duel.AnnounceNumberRange(tp,0,9)
	local thousand=Duel.AnnounceNumberRange(tp,0,100)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SetLP(tp,one*1+ten*10+hundred*100+thousand*1000,REASON_EFFECT)
end
--op lp set
function s.lpop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local one=Duel.AnnounceNumberRange(tp,0,9)
	local ten=Duel.AnnounceNumberRange(tp,0,9)
	local hundred=Duel.AnnounceNumberRange(tp,0,9)
	local thousand=Duel.AnnounceNumberRange(tp,0,100)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SetLP(1-tp,one*1+ten*10+hundred*100+thousand*1000,REASON_EFFECT)
end