
state Bash in MCD_Manager extends Kick {
  default repel_type = PRT_Bash;
  default animation_duration = 1.333;


  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    LogChannel('MCS', "BASH");

    this.Bash_start();
    parent.GotoState('Waiting');
  }

  entry function Bash_start() {
    var is_too_far: bool;
    is_too_far = this.isTooFarAway();

    if (is_too_far && !mcd_getPhysicalSkillCanMiss()) {
      // have no other choice than to do this now.
      // otherwise the skill gets in cooldown even
      // when it misses.
      resetPhysicalSkillCooldown();
      
      return;
    }

    if (!is_too_far) {
      this.doMovementAdjustment();
    }

    this.Bash_playGeraltAnimation();
    this.drainPlayerStamina();

    if (!is_too_far) {
      this.tryStaggerTarget();
    }
  }

  latent function Bash_playGeraltAnimation() {
    if (RandRange(10) < 5) {
      thePlayer
      .ActionPlaySlotAnimationAsync('PLAYER_SLOT','combatskills_man_geralt_sword_repel_rp_bash', 0.1, 1, false);
    }
    else {
      thePlayer
      .ActionPlaySlotAnimationAsync('PLAYER_SLOT','combatskills_man_geralt_sword_repel_lp_bash', 0.1, 1, false);
    }
  }

  event OnLeaveState( nextStateName : name ) {
    super.OnLeaveState(nextStateName);
  }
}
