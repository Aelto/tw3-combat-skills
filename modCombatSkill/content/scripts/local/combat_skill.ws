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
// Geralt won't parry.
function modCombatSkillHandleActions(action: SInputAction): bool {
  // going sideways
  if (theInput.GetActionValue('GI_AxisLeftX') != 0) {
    if (canPerformSidestepSkill()) {
      performMeleeSkill(PRT_SideStepSlash);

      updateSidestepSkillCooldown();
      
      // early return to cancel the parry action
      return true;
    }
  }

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

  if (repeltype == PRT_SideStepSlash) {
    geraltSlideAwayFromNearbyTargets(2);
  }
  else {
    thePlayer.UpdateCustomRotationHeading('MeleeSkill', VecHeading(target.GetWorldPosition() - thePlayer.GetWorldPosition()));
    thePlayer.SetCustomRotation('MeleeSkill', VecHeading(target.GetWorldPosition() - thePlayer.GetWorldPosition()), 0.f, 0.2f, false);

    if (distance < 2.25) {
      // if Geralt is further than two meters
      if (distance > 2) {
        // slide him closer so the kick hits
        geraltSlideAwayFromTarget(thePlayer.GetTarget());
      }

      // Geralt attempt at kicking or bashing a huge creature.
      if (target.IsHuge()) {
        // only stagger the enemy if geralt has the required stamina
        if (thePlayer.HasStaminaToUseAction(ESAT_Roll, , , 2)) {
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
        drainPlayerStaminaAgainstHugeCreature();
      }
      else {
        target.SetBehaviorVariable('repelType', (int)repeltype);
        target.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
      }
    }
  }

  drainPlayerStamina(repeltype);

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

function drainPlayerStamina(repelType: EPlayerRepelType) {
  thePlayer.DrainStamina(
    ESAT_HeavyAttack,
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