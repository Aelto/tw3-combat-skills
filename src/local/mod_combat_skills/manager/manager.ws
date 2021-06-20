
statemachine class MCD_Manager extends CEntity {

}

function MCD_managerGoToStateSidestep() {
  var props: modCombatSkill_properties;

  props = thePlayer.GetInputHandler()
    .mod_combat_skill_properties;

  props.manager.GotoState('Sidestep');
}

function MCD_managerGoToStateKick() {
  var props: modCombatSkill_properties;

  props = thePlayer.GetInputHandler()
    .mod_combat_skill_properties;

  props.manager.GotoState('Kick');
}

function MCD_managerGoToStateBash() {
  var props: modCombatSkill_properties;

  props = thePlayer.GetInputHandler()
    .mod_combat_skill_properties;

  props.manager.GotoState('Bash');
}

function MCD_managerGoToStateShortDodge() {
  var props: modCombatSkill_properties;

  props = thePlayer.GetInputHandler()
    .mod_combat_skill_properties;

  props.manager.GotoState('ShortDodge');
}