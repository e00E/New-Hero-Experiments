test_ability = class({})

function test_ability:OnSpellStart()
	if self:GetCursorTarget() then
		target = self:GetCursorTarget()
		print(target:GetTeam())
	else
		
	end
end
