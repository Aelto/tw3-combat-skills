// modCombatSkill - BEGIN


// Keywords to know:
// - A physical skill is either shoulder bash or kick
// - A sidestep skill is a sidestep slash
// - A melee skill is both a physical skill and a sidestep skill

// Where to start:
// everything in this mod starts from `modCombatSkillHandleActions()`
// if you're looking for the changes made in code, search for this function.

// if this function returns true, the current input event is cancelled early
// Geralt won't parry.
function modCombatSkillHandleActions(action: SInputAction): bool {
  if (!mcd_isEnabled()
   || !thePlayer.HasWeaponDrawn(false)
   || thePlayer.HasBuff(EET_Tangled)) {
    return false;
  }

  tryInstantiateCombatSkillManager();

  // checking for sidesteps
  if (shouldBindTrigger(mcd_getSidestepBind())) {
    if (canPerformSidestepSkill() && hasEnoughStamina(PRT_SideStepSlash)) {
      updateSidestepSkillCooldown();
      MCD_managerGoToStateSidestep();
      
      // early return to cancel the parry action
      return true;
    }
  }

  // then for the kick
  if (shouldBindTrigger(mcd_getKickBind())) {
    if (canPerformPhysicalSkill() && hasEnoughStamina(PRT_Kick)) {
      updatePhysicalSkillCooldown();
      MCD_managerGoToStateKick();
      
      // early return to cancel the parry action
      return true;
    }
  }

  // and finally the shoulder bash
  if (shouldBindTrigger(mcd_getShoulderBind())) {
    if (canPerformPhysicalSkill() && hasEnoughStamina(PRT_Bash)) {
      updatePhysicalSkillCooldown();
      MCD_managerGoToStateBash();
      
      // early return to cancel the parry action
      return true;
    }
  }

  return false;
}

function shouldBindTrigger(bind: MCD_SkillBind): bool {
  return bind == MCD_SkillBind_Forward && theInput.GetActionValue('GI_AxisLeftY') > 0.85
      || bind == MCD_SkillBind_Left && theInput.GetActionValue('GI_AxisLeftX') < -0.85
      || bind == MCD_SkillBind_Backward && theInput.GetActionValue('GI_AxisLeftY') < -0.85
      || bind == MCD_SkillBind_Right && theInput.GetActionValue('GI_AxisLeftX') > 0.85
      || bind == MCD_SkillBind_ForwardOrBackward && theInput.GetActionValue('GI_AxisLeftY') != 0
      || bind == MCD_SkillBind_LeftOrRight && theInput.GetActionValue('GI_AxisLeftX') != 0;
}

function canPerformPhysicalSkill(): bool {
  var props: modCombatSkill_properties;

  props = thePlayer.GetInputHandler()
    .mod_combat_skill_properties;

  return theGame.GetEngineTimeAsSeconds() - props.last_physical_skill_time > props.physical_skill_cooldown;
}

function updatePhysicalSkillCooldown() {
  var player_input: CPlayerInput;

  player_input = thePlayer.GetInputHandler();

  player_input.mod_combat_skill_properties.last_physical_skill_time = theGame.GetEngineTimeAsSeconds();
}

function resetPhysicalSkillCooldown() {
  var player_input: CPlayerInput;

  player_input = thePlayer.GetInputHandler();

  player_input.mod_combat_skill_properties.last_physical_skill_time = 0;
}

function canPerformSidestepSkill(): bool {
  var props: modCombatSkill_properties;

  props = thePlayer.GetInputHandler()
    .mod_combat_skill_properties;

  return theGame.GetEngineTimeAsSeconds() - props.last_sidestep_skill_time > props.sidestep_skill_cooldown;
}

function updateSidestepSkillCooldown() {
  var player_input: CPlayerInput;

  player_input = thePlayer.GetInputHandler();

  player_input.mod_combat_skill_properties.last_sidestep_skill_time = theGame.GetEngineTimeAsSeconds();
}

function tryInstantiateCombatSkillManager() {
  var player_input: CPlayerInput;

  player_input = thePlayer.GetInputHandler();

  if (!player_input.mod_combat_skill_properties.manager_instantiated) {
    player_input.mod_combat_skill_properties.manager = new MCD_Manager in player_input;

    if (!mcd_isInitialized()) {
      mcd_initializeSettings();
      displayModCombatSkillsInitializedNotification();
    }
  }
}

function staminaCostTypeToActionType(cost_type: MCD_StaminaCostType): EStaminaActionType {
  if (cost_type == MCD_StaminaCostType_None) {
    return ESAT_Undefined;
  }
  else if (cost_type == MCD_StaminaCostType_LightAttack) {
    return ESAT_LightAttack;
  }
  else if (cost_type == MCD_StaminaCostType_HeavyAttack) {
    return ESAT_HeavyAttack;
  }
  else if (cost_type == MCD_StaminaCostType_Rend) {
    return ESAT_SuperHeavyAttack;
  }
  else if (cost_type == MCD_StaminaCostType_Dodge) {
    return ESAT_Dodge;
  }
  else if (cost_type == MCD_StaminaCostType_Roll) {
    return ESAT_Roll;
  }

  return ESAT_Undefined;
}

function hasEnoughStamina(repelType: EPlayerRepelType, optional is_huge: bool): bool {
  var cost: EStaminaActionType;
  var multiplier: float;

  if (repelType == PRT_Kick || repelType == PRT_Bash) {
    cost = staminaCostTypeToActionType(
      mcd_getPhysicalSKillStaminaCostType()
    );

    multiplier = mcd_getPhysicalSKillStaminaCostMultiplier();
  }
  else {
    cost = staminaCostTypeToActionType(
      mcd_getSidestepSKillStaminaCostType()
    );

    multiplier = mcd_getSidestepSKillStaminaCostMultiplier();
  }

  if (multiplier <= 0 || cost == ESAT_Undefined) {
    return true;
  }

  if (is_huge) {
    multiplier *= 2;
  }

  return thePlayer.HasStaminaToUseAction(
    cost,,,
    multiplier
  );
}
// modCombatSkill - END