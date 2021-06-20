abstract state SkillBase in MCD_Manager {
  var repel_type: EPlayerRepelType;
  default repel_type = PRT_Kick;

  var animation_duration: float;
  default animation_duration = 1;

  function getStaminaCost(): EStaminaActionType {
    return ESAT_Undefined;
  }

  function getStaminaMultiplier(): float {
    return 1;
  }

  function drainPlayerStamina(optional is_huge: bool) {
    var cost: EStaminaActionType;
    var multiplier: float;

    cost = this.getStaminaCost();
    multiplier = this.getStaminaMultiplier();

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

  function playerHasEnoughStamina(optional is_huge: bool): bool {
    var multiplier: float;

    multiplier = this.getStaminaMultiplier();

    if (is_huge) {
      multiplier *= 2;
    }

    return thePlayer.HasStaminaToUseAction(
      this.getStaminaCost(),,,
      multiplier
    );
  }

  function doMovementAdjustment() {
    var movement_adjustor: CMovementAdjustor;
    var slide_ticket: SMovementAdjustmentRequestTicket;

    movement_adjustor = thePlayer
      .GetMovingAgentComponent()
      .GetMovementAdjustor();

    slide_ticket = movement_adjustor.GetRequest( 'ShortDodge' );

    // cancel any adjustement made with the same name
    movement_adjustor.CancelByName( 'ShortDodge' );

    // and now we create a new request
    slide_ticket = movement_adjustor.CreateNewRequest( 'ShortDodge' );

    movement_adjustor.AdjustmentDuration(
      slide_ticket,
      0.25 // 250ms
    );

    // movement_adjustor.SlideTowards(
    //   slide_ticket,
    //   target,
    //   1.5 // min distance of 1.5m between Geralt and the target
    // );

    // movement_adjustor.RotateTowards(
    //   slide_ticket,
    //   target
    // );

    movement_adjustor.MaxLocationAdjustmentDistance(
      slide_ticket,
      , // speed
      1, // max distance on x and y
    );
  }

  event OnLeaveState( nextStateName : name ) {
    super.OnLeaveState(nextStateName);
  }
}