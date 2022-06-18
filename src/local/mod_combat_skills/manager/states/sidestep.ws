
state Sidestep in MCD_Manager extends SkillBase {
  default repel_type = PRT_SideStepSlash;
  default animation_duration = 1.5;

  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    LogChannel('MCS', "SIDESTEP");

    this.Sidestep_start();
    parent.GotoState('Waiting');
  }

  entry function Sidestep_start() {
    var is_too_far: bool;
    is_too_far = this.isTooFarAway();

    if (is_too_far && !mcd_getPhysicalSkillCanMiss()) {
      // have no other choice than to do this now.
      // otherwise the skill gets in cooldown even
      // when it misses.
      resetPhysicalSkillCooldown();
      
      return;
    }

    this.doMovementAdjustment();
    this.Sidestep_playGeraltAnimation();
    this.drainPlayerStamina();
    this.handleInvulnerabilityFrame();
  }

  latent function Sidestep_playGeraltAnimation() {
    // going left
    if (theInput.GetActionValue('GI_AxisLeftX') > 0) {
      if (RandRange(10) < 5) {
        thePlayer
        .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_sidestep_counter_left_lp', 0.1, 1, false);
      }
      else {
        thePlayer
        .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_sidestep_counter_left_rp', 0.1, 1, false);
      }
    }
    // going right
    else {
      if (RandRange(10) < 5) {
        thePlayer
        .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_sidestep_counter_right_lp', 0.1, 1, false);
      }
      else {
        thePlayer
        .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_sidestep_counter_right_rp', 0.1, 1, false);
      }
    }
  }

  latent function handleInvulnerabilityFrame() {
    var sidestep_invulnerability_duration: float;
    
    sidestep_invulnerability_duration = mcd_getSidestepInvulnerabilityDuration();

    if (sidestep_invulnerability_duration <= 0) {
      return;
    }

    Sleep(mcd_getSidestepInvulnerabilityStart());

    thePlayer.SetIsCurrentlyDodging(true, true);

    Sleep(sidestep_invulnerability_duration);

    thePlayer.SetIsCurrentlyDodging(false, true);
  }

  function doMovementAdjustment() {
    var i: int;
    var entities: array<CGameplayEntity>;
    var mean_vector: Vector;
    var movement_adjustor: CMovementAdjustor;
    var slide_ticket: SMovementAdjustmentRequestTicket;

    FindGameplayEntitiesInRange(
      entities,
      thePlayer,
      2,
      3,
      ,
      FLAG_ExcludePlayer + FLAG_OnlyAliveActors + FLAG_Attitude_Hostile
    );

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

    movement_adjustor.MaxLocationAdjustmentDistance(
      slide_ticket,
      , // speed
      0.5, // max distance on x and y
    );
  }

  function isTooFarAway(): bool {
    return VecDistance(
      thePlayer.GetWorldPosition(),
      thePlayer.GetTarget().GetWorldPosition(),
    ) > 3;
  }

  function getStaminaCost(): EStaminaActionType {
    return staminaCostTypeToActionType(
      mcd_getSidestepSKillStaminaCostType()
    );
  }

  function getStaminaMultiplier(): float {
    return mcd_getSidestepSKillStaminaCostMultiplier();;
  }
}
