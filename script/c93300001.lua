--Barian Degeneracy
--Scripted by TDH Project
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- helper
local function contains(tbl,val)
	for _,v in ipairs(tbl) do if v==val then return true end end
	return false
end

-- groups
s.groupX={8487449,73580471,23874409,66976526,25904894,511001992} -- IDs of monsters you can banish
s.groupY={85545073,93300002,511001992,511001993} -- IDs of monsters you can summon

-- You must have at least 1 summonable monster in Extra Deck
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filterY,tp,LOCATION_EXTRA,0,1,nil,e,tp)
end

function s.filterX(c)
	return contains(s.groupX,c:GetCode()) and c:IsAbleToRemove()
end
function s.filterY(c,e,tp)
	return contains(s.groupY,c:GetCode()) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.filterX(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filterX,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
			and Duel.GetLocationCountFromEx(tp,tp,nil)>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filterX,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
	if Duel.GetLocationCountFromEx(tp,tp,nil)<=0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filterY,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		local sc=g:GetFirst()
		Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
		sc:CompleteProcedure()
	end

end
