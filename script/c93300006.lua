--Barian Corruption
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
-- check if opponent activated a monster effect or Spell/Trap activation
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsChainNegatable(ev) then return false end
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsControler(1-tp) and rc:IsLocation(LOCATION_MZONE) then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,rc,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not Duel.NegateActivation(ev) then return end
	-- If the negated card was a monster your opponent controlled on the field
	if re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToEffect(re)
		and rc:IsControler(1-tp) and rc:IsLocation(LOCATION_MZONE)
		and rc:IsFaceup() then
		-- Ask player to declare a monster card by code (returns an integer code)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCard(tp)
		if not ac or ac==0 then return end -- safety
		-- Change its name to the declared monster's code
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
		-- Then take control of it
		Duel.BreakEffect()
		Duel.GetControl(rc,tp)
	end
end
