
statemachine class MCD_Manager extends CEntity {

}

function MCD_managerGoToStateSidestep() {
  var props: modCombatSkill_properties;

  props = thePlayer.GetInputHandler()
    .mod_combat_skill_properties;

  props.manager.GotoState('Sidestep');
}