// modCombatSkill - BEGIN

// Keywords to know:
// - A physical skill is either shoulder bash or kick
// - A sidestep skill is a sidestep slash
// - A melee skill is both a physical skill and a sidestep skill

// Where to start:
// everything in this mod starts from `modCombatSkillHandleActions()`
// if you're looking for the changes made in code, search for this function.

// a struct for the variables to avoid changing too much code in the game scripts
// this way only one variable is created and it is this struct with many members
struct modCombatSkill_properties {

  // the cooldown for physical skills: shoulder-bash & kick
  // the cooldown for such skills is set to 1second.
  // If you wish to change that, change the 1 below to something else.
  var physical_skill_cooldown: float;
  default physical_skill_cooldown = 1; 

  // the cooldown for sidestep skills: sidestep-slash.
  // the cooldown for suck skills is set to 0.75second.
  // If you wish to change that, change the 0.75 below to something else.
  var sidestep_skill_cooldown: float;
  default sidestep_skill_cooldown = 0.75;

  // the two variables below are used to calculate the cooldown of the skills
  // everytime the user uses one, the timestamp is stored into this variable.
  // So that everytime a skill is used, we check the delta between the current
  // and the last timestamp and if the delta is greater than the cooldown, then
  // it means the skill is up. If not, it means the skill is still in cooldown
  // and nothing happens.
  var last_physical_skill_time: float;
  var last_sidestep_skill_time: float;

}

// if this function returns true, the current input event is cancelled early
// Geralt won't parry,
function modCombatSkillHandleActions(action: SInputAction): bool {
  // going forward
  if (theInput.GetActionValue('GI_AxisLeftY') > 0.85) {
    if (canPerformPhysicalSkill()) {
      performMeleeSkill(PRT_Kick);

      updatePhysicalSkillCooldown();
      
      // early return to cancel the parry action
      return true;
    }
  }

  // going backward
  if (theInput.GetActionValue('GI_AxisLeftY') < -0.85) {
    if (canPerformPhysicalSkill()) {
      performMeleeSkill(PRT_Bash);

      updatePhysicalSkillCooldown();
      
      // early return to cancel the parry action
      return true;
    }
  }

  // going sideways
  if (theInput.GetActionValue('GI_AxisLeftX') != 0) {
    if (canPerformSidestepSkill()) {
      performMeleeSkill(PRT_SideStepSlash);

      updateSidestepSkillCooldown();
      
      // early return to cancel the parry action
      return true;
    }
  }

  return false;
}

function performMeleeSkill(repeltype: EPlayerRepelType) {
  var target: CActor;
  var distance: float;

  // update the player's target
  thePlayer.FindTarget();

  target = thePlayer.GetTarget();
  distance = VecDistance(target.GetWorldPosition(), thePlayer.GetWorldPosition());

  thePlayer.SetBehaviorVariable('repelType', (int)repeltype);

  //                     || or else the target is stuck in a T-pose
  //                     || for some reason, the sidestep, if done at the right
  //                     || time will force a T-pose to creatures. It looks like
  //                     \/ the game doesn't expect the slash to stagger.
  if (distance < 2 && repeltype != PRT_SideStepSlash) {
    // Geralt attempt at kicking or bashing a huge creature.
    if (target.IsHuge()) {
      // if Geralt doesn't have the stamina for 2 rolls
      // he gets staggered instead
      if (!thePlayer.HasStaminaToUseAction(ESAT_Roll, , , 2)) {
        thePlayer.SetBehaviorVariable('repelType', (int)repeltype);
        thePlayer.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
      }

      // note that this stamina drain is on top of the default stamina cost
      drainPlayerStaminaAgainstHugeCreature();
    }
    else {
      target.SetBehaviorVariable('repelType', (int)repeltype);
      target.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
    }
  }

  if (repeltype == PRT_SideStepSlash) {
    geraltSlideAwayFromTarget();
  }

  drainPlayerStamina(repeltype);

  thePlayer.UpdateCustomRotationHeading('MeleeSkill', VecHeading(target.GetWorldPosition() - thePlayer.GetWorldPosition()));
  thePlayer.SetCustomRotation('MeleeSkill', VecHeading(target.GetWorldPosition() - thePlayer.GetWorldPosition()), 0.f, 0.2f, false);

  thePlayer.RaiseForceEvent('PerformCounter');
  thePlayer.OnCombatActionStart();
}

// function getPhysicalSkillStaminaCost(): float {
//   var menu_value: string;
//   var multiplier: float;
//   var reference_value: float;

//   menu_value = theGame
//     .GetInGameConfigWrapper()
//     .inGameConfigWrapper.GetVarValue('CombatSkill', 'CSphysicalSkillStaminaCost');

//   multiplier = StringToFloat(menu_value);
//   reference_value = 3; // TODO: use the light attack stamina cost or 0 for vanilla

//   return reference_value * multiplier;
// }

// function getSidestepSkillStaminaCost(): float {
//   var menu_value: string;
//   var multiplier: float;
//   var reference_value: float;

//   menu_value = theGame
//     .GetInGameConfigWrapper()
//     .inGameConfigWrapper.GetVarValue('CombatSkill', 'CSsidestepSkillStaminaCost');

//   multiplier = StringToFloat(menu_value);
//   reference_value = 3; // TODO: use the light attack stamina cost or 0 for vanilla

//   return reference_value * multiplier;
// }

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

  return theGame.GetEngineTimeAsSeconds() - props.sidestep_skill_cooldown > props.sidestep_skill_cooldown;
}

function updateSidestepSkillCooldown() {
  var player_input: CPlayerInput;

  player_input = thePlayer.GetInputHandler();

  player_input.mod_combat_skill_properties.last_sidestep_skill_time = theGame.GetEngineTimeAsSeconds();
}

function drainPlayerStamina(repelType: EPlayerRepelType) {
  thePlayer.DrainStamina(
    ESAT_LightAttack,
    , // fixed value
    , // fixed delay
    , // ability name
    1, // pause stamina regen duration
    // todo: add cost mult
  );
}

function drainPlayerStaminaAgainstHugeCreature() {
  thePlayer.DrainStamina(
    ESAT_Roll,
    , // fixed value
    , // fixed delay
    , // ability name
    1, // pause stamina regen duration
    2// todo: add cost mult
  );
}

function geraltSlideAwayFromTarget() {
  var movementAdjustor: CMovementAdjustor;
	var slide_ticket: SMovementAdjustmentRequestTicket;

  movementAdjustor = thePlayer
    .GetMovingAgentComponent()
    .GetMovementAdjustor();

  slide_ticket = movementAdjustor.GetRequest( 'SidestepAwayFromTarget' );

  // cancel any adjustement made with the same name
  movementAdjustor.CancelByName( 'SidestepAwayFromTarget' );

  // and now we create a new request
  slide_ticket = movementAdjustor.CreateNewRequest( 'SidestepAwayFromTarget' );

  movement_adjustor.AdjustmentDuration(
    slide_ticket,
    0.25 // 250ms
  );

  // TODO: there is an interesting method in the movement_adjustor: ScaleAnimation
  // Maybe we could use it instead of doing hard Rotates and Slides and we  would
  // scale the sidestep animation

  movement_adjustor.SlideTowards(
    slide_ticket,
    thePlayer.GetTarget(),
    1.5 // min distance of 1.5m between Geralt and the target
  );

  movement_adjustor.RotateTowards(
    slide_ticket,
    thePlayer.GetTarget()
  );
}
// modCombatSkill - END