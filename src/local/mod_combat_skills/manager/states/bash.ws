
state Bash in MCD_Manager extends Kick {
  default repel_type = PRT_Bash;
  default animation_duration = 1.333;


  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    this.Bash_start();
    parent.GotoState('Waiting');
  }

  entry function Bash_start() {
    if (this.isTooFarAway()) {
      return;
    }

    this.doMovementAdjustment();
    this.Bash_playGeraltAnimation();
    this.drainPlayerStamina();
    this.tryStaggerTarget();
  }

  latent function Bash_playGeraltAnimation() {
    if (RandRange(10) < 5) {
      thePlayer
      .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_repel_rp_bash', 0, 1, false);
    }
    else {
      thePlayer
      .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_repel_lp_bash', 0, 1, false);
    }
  }

  event OnLeaveState( nextStateName : name ) {
    super.OnLeaveState(nextStateName);
  }
}
