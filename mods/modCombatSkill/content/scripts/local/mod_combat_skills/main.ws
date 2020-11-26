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

  tryInstantiateCombatSkillManager();

  // checking for sidesteps
  if (shouldBindTrigger(mcd_getSidestepBind())) {
    if (canPerformSidestepSkill() && hasEnoughStamina(PRT_SideStepSlash)) {
      performMeleeSkill(PRT_SideStepSlash);

      updateSidestepSkillCooldown();
      
      // early return to cancel the parry action
      return true;
    }
  }

  // then for the kick
  if (shouldBindTrigger(mcd_getKickBind())) {
    if (canPerformPhysicalSkill() && hasEnoughStamina(PRT_Kick)) {
      performMeleeSkill(PRT_Kick);

      updatePhysicalSkillCooldown();
      
      // early return to cancel the parry action
      return true;
    }
  }

  // and finally the shoulder bash
  if (shouldBindTrigger(mcd_getShoulderBind())) {
    if (canPerformPhysicalSkill() && hasEnoughStamina(PRT_Bash)) {
      performMeleeSkill(PRT_Bash);

      updatePhysicalSkillCooldown();
      
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

function performMeleeSkill(repeltype: EPlayerRepelType) {
  var target: CActor;
  var distance: float;

  // update the player's target
  thePlayer.FindTarget();

  target = thePlayer.GetTarget();
  distance = VecDistance(target.GetWorldPosition(), thePlayer.GetWorldPosition());

  if (repeltype == PRT_SideStepSlash) {
    geraltSlideAwayFromNearbyTargets(2);

    MCD_managerGoToStateSidestep();
  }
  else {
    if (distance < 3) {
      // if Geralt is further than two meters
      if (distance > 2) {
        // slide him closer so the kick hits
        geraltSlideAwayFromTarget(thePlayer.GetTarget());
      }

      // Geralt attempt at kicking or bashing a huge creature.
      if (target.IsHuge()) {
        // only stagger the enemy if geralt has the required stamina
        if (hasEnoughStamina(repeltype, true)) {
          target.SetBehaviorVariable('repelType', (int)repeltype);
          target.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
        }
        // if Geralt doesn't have the stamina for 2 rolls
        // he gets staggered instead
        else {
          thePlayer.SetBehaviorVariable('repelType', (int)repeltype);
          thePlayer.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
        }

        // note that this stamina drain is on top of the default stamina cost
        // and is called no matter the current stamina levels. It means that simply
        // trying to kick a huge creature costs additional stamina
        drainPlayerStamina(repeltype, true);
      }
      else {
        target.SetBehaviorVariable('repelType', (int)repeltype);
        
        if (!target.HasBuff(EET_Knockdown) && !target.HasBuff(EET_HeavyKnockdown)) {
          target.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
        }
      }
    }
    // out of range and the user doesn't allow the skills to miss.
    // So we leave early and do nothing
    else if (!mcd_getPhysicalSkillCanMiss()) {
			theSound.SoundEvent("gui_global_denied");

      return;
    }

    thePlayer.UpdateCustomRotationHeading('MeleeSkill', VecHeading(target.GetWorldPosition() - thePlayer.GetWorldPosition()));
    thePlayer.SetCustomRotation('MeleeSkill', VecHeading(target.GetWorldPosition() - thePlayer.GetWorldPosition()), 0.f, 0.2f, false);
  }

  drainPlayerStamina(repeltype);
  thePlayer.SetBehaviorVariable('repelType', (int)repeltype);
  thePlayer.RaiseForceEvent('PerformCounter');
  thePlayer.OnCombatActionStart();
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

function drainPlayerStamina(repelType: EPlayerRepelType, optional is_huge: bool) {
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
    return;
  }

  if (is_huge) {
    multiplier *= 2;
  }

  thePlayer.DrainStamina(
    cost,
    , // fixed value
    , // fixed delay
    , // ability name
    1, // pause stamina regen duration
    multiplier
  );
}

function geraltSlideAwayFromNearbyTargets(radius: float) {
  var i: int;
  var entities: array<CGameplayEntity>;
  var mean_vector: Vector;
  var movement_adjustor: CMovementAdjustor;
	var slide_ticket: SMovementAdjustmentRequestTicket;

  FindGameplayEntitiesInRange(
    entities,
    thePlayer,
    radius,
    3,
    ,
    FLAG_ExcludePlayer + FLAG_OnlyAliveActors + FLAG_Attitude_Hostile
  );

  for (i = 0; i < entities.Size(); i += 1) {
    mean_vector += entities[i].GetWorldPosition();
  }

  mean_vector /= entities.Size();


  movement_adjustor = thePlayer
    .GetMovingAgentComponent()
    .GetMovementAdjustor();

  slide_ticket = movement_adjustor.GetRequest( 'SidestepAwayFromNearbyTargets' );

  // cancel any adjustement made with the same name
  movement_adjustor.CancelByName( 'SidestepAwayFromNearbyTargets' );

  // and now we create a new request
  slide_ticket = movement_adjustor.CreateNewRequest( 'SidestepAwayFromNearbyTargets' );

  movement_adjustor.AdjustmentDuration(
    slide_ticket,
    0.25 // 250ms
  );

  // movement_adjustor.LockMovementInDirection(
  //   slide_ticket,
  //   VecHeading(
  //     mean_vector - thePlayer.GetWorldPosition()
  //   ) - 90
  // );

  for (i = 0; i < entities.Size(); i += 1) {
    movement_adjustor.SlideTowards(
      slide_ticket,
      entities[i],
      1.5 // min distance of 1m between Geralt and the target
    );

    // movement_adjustor.SlideTo(
    //   slide_ticket,
    //   VecInterpolate(
    //     thePlayer.GetWorldPosition(),
    //     mean_vector,
    //     0.1
    //   )
    // );

    movement_adjustor.RotateTowards(
      slide_ticket,
      entities[i]
    );
  }
}

function geraltSlideAwayFromTarget(target: CNode) {
  var movement_adjustor: CMovementAdjustor;
	var slide_ticket: SMovementAdjustmentRequestTicket;

  movement_adjustor = thePlayer
    .GetMovingAgentComponent()
    .GetMovementAdjustor();

  slide_ticket = movement_adjustor.GetRequest( 'SidestepAwayFromTarget' );

  // cancel any adjustement made with the same name
  movement_adjustor.CancelByName( 'SidestepAwayFromTarget' );

  // and now we create a new request
  slide_ticket = movement_adjustor.CreateNewRequest( 'SidestepAwayFromTarget' );

  movement_adjustor.AdjustmentDuration(
    slide_ticket,
    0.25 // 250ms
  );

  movement_adjustor.SlideTowards(
    slide_ticket,
    target,
    1.5 // min distance of 1.5m between Geralt and the target
  );

  movement_adjustor.RotateTowards(
    slide_ticket,
    target
  );
}
// modCombatSkill - END