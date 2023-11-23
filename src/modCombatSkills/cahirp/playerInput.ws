@context(
  file(game/player/playerInput.ws)
  at(class CPlayerInput)
)

@insert(
  note("declare the variable holding the combat skills properties")
  above(event OnCommGuard( action : SInputAction ))
)
// modCombatSkill - BEGIN
public var mod_combat_skill_properties: modCombatSkill_properties;
// modCombatSkill - END

@insert(
  note("add combat skills short-circuit on the parry action to perform kicks/slashes")
  at(event OnCommGuard( action : SInputAction ))
  at(if ( !thePlayer.IsInsideInteraction() ))
  at(if (  IsActionAllowed(EIAB_Parry) ))
  above(if( IsPressed(action) ))
)
// modCombatSkill - BEGIN
if (modCombatSkillHandleActions(action)) {
  return false;
}
// modCombatSkill - END

@insert(
  note("add combat skills short-circuit on the parry action to perform kicks/slashes")
  at(event OnCbtLockAndGuard( action : SInputAction ))
  at(if( IsPressed(action) ))
  at(if ( thePlayer.GetCurrentStateName() == 'Exploration' ))
  above(if ( thePlayer.bLAxisReleased ))
)
// modCombatSkill - BEGIN
if (modCombatSkillHandleActions(action)) {
  return false;
}
// modCombatSkill - END