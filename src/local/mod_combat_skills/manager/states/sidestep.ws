
state Sidestep in MCD_Manager {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    this.Sidestep_start();
    parent.GotoState('Waiting');
  }

  entry function Sidestep_start() {
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
}
