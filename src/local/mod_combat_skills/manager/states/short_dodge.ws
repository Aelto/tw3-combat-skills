
state ShortDodge in MCD_Manager {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    LogChannel('MCS', "ShortDodge");

    this.ShortDodge_start();
    parent.GotoState('Waiting');
  }

  entry function ShortDodge_start() {
    var starting_position: Vector;

    starting_position = thePlayer.GetWorldPosition();

    SleepOneFrame();
    SleepOneFrame();
    SleepOneFrame();
    SleepOneFrame();
    SleepOneFrame();
    SleepOneFrame();
    this.doMovementAdjustment(starting_position);
  }

  latent function doMovementAdjustment(starting_position: Vector) {
    var movement_adjustor: CMovementAdjustor;
    var slide_ticket: SMovementAdjustmentRequestTicket;
    var entities: array<CGameplayEntity>;
    var i: int;

    // starting_position = thePlayer.GetWorldPosition();

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

    // NDEBUG("ShortDodge");

    slide_ticket = movement_adjustor.GetRequest( 'ShortDodge' );

    // cancel any adjustement made with the same name
    movement_adjustor.CancelByName( 'ShortDodge' );

    // and now we create a new request
    slide_ticket = movement_adjustor.CreateNewRequest( 'ShortDodge' );

    // movement_adjustor.AdjustmentDuration(
    //   slide_ticket,
    //   .25 // 250ms
    // );

    

    movement_adjustor.DontEnd(slide_ticket);
    movement_adjustor.ReplaceTranslation(slide_ticket, true);
    // movement_adjustor.MaxLocationAdjustmentSpeed(slide_ticket, 50);
    // movement_adjustor.SlideTo(
    //   slide_ticket,
    //   starting_position
    // );

    NDEBUG(VecToString(starting_position - thePlayer.GetWorldPosition()));

    movement_adjustor.SlideBy(
      slide_ticket,
      (starting_position - thePlayer.GetWorldPosition()) * 2
    );

    // movement_adjustor.MaxLocationAdjustmentDistance(
    //   slide_ticket,
    //   , // speed
    //   mcd_getShortDodgeMaximumDistance(), // max distance on x and y
    // );

    // NDEBUG(entities.Size() + " qd");
    // for (i = 0; i < entities.Size(); i += 1) {
    //   movement_adjustor.SlideTowards(
    //     slide_ticket,
    //     entities[i],
    //     1.5 // min distance of 1m between Geralt and the target
    //   );

    //   // movement_adjustor.RotateTowards(
    //   //   slide_ticket,
    //   //   entities[i]
    //   // );
    // }


    while (thePlayer.IsCurrentlyDodging()) {
      SleepOneFrame();
    }

    movement_adjustor.Cancel(slide_ticket);
  }

  event OnLeaveState( nextStateName : name ) {
    super.OnLeaveState(nextStateName);

    thePlayer
      .GetMovingAgentComponent()
      .GetMovementAdjustor()
      .CancelByName('ShortDodge');
  }
}
