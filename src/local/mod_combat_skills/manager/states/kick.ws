
state Kick in MCD_Manager extends SkillBase {
  default repel_type = PRT_Kick;
  default animation_duration = 1.233;

  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    LogChannel('MCS', "KICK");

    this.Kick_start();
    parent.GotoState('Waiting');
  }

  entry function Kick_start() {
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

    // thePlayer.OnCombatActionStart();
    
    this.Kick_playGeraltAnimation();
    this.drainPlayerStamina();

    if (!is_too_far) {
      this.tryStaggerTarget();
    }
  }

  function isTooFarAway(): bool {
    return VecDistance(
      thePlayer.GetWorldPosition(),
      thePlayer.GetTarget().GetWorldPosition(),
    ) > 3;
  }

  latent function Kick_playGeraltAnimation() {
    if (RandRange(10) < 5) {
		  thePlayer
        .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_repel_rp_kick', 0.1, 1, false);
    }
    else {
		  thePlayer
        .ActionPlaySlotAnimationAsync('PLAYER_SLOT','man_geralt_sword_repel_lp_kick', 0.1, 1, false);
    }
  }

  function tryStaggerTarget() {
    var target: CActor;

    target = thePlayer.GetTarget();

    // Geralt attempt at kicking or bashing a huge creature.
    if (target.IsHuge()) {
      // only stagger the enemy if geralt has the required stamina
      if (this.playerHasEnoughStamina(true)) {
        target.SetBehaviorVariable('repelType', (int)this.repel_type);

        if (!target.HasBuff(EET_Knockdown) && !target.HasBuff(EET_HeavyKnockdown) && !target.HasBuff(EET_CounterStrikeHit)) {
          target.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
        }
      }
      // if Geralt doesn't have the stamina for 2 rolls
      // he gets staggered instead
      else {
        thePlayer.SetBehaviorVariable('repelType', (int)this.repel_type);
        thePlayer.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
      }

      // note that this stamina drain is on top of the default stamina cost
      // and is called no matter the current stamina levels. It means that simply
      // trying to kick a huge creature costs additional stamina
      this.drainPlayerStamina(true);
    }
    else {
      target.SetBehaviorVariable('repelType', (int)this.repel_type);
      
      if (!target.HasBuff(EET_Knockdown) && !target.HasBuff(EET_HeavyKnockdown) && !target.HasBuff(EET_CounterStrikeHit)) {
        target.AddEffectDefault(EET_CounterStrikeHit, thePlayer, "ReflexParryPerformed");
      }
    }
  }

  function getStaminaCost(): EStaminaActionType {
    return staminaCostTypeToActionType(
      mcd_getPhysicalSKillStaminaCostType()
    );
  }

  function getStaminaMultiplier(): float {
    return mcd_getPhysicalSKillStaminaCostMultiplier();;
  }

  event OnLeaveState( nextStateName : name ) {
    super.OnLeaveState(nextStateName);
  }
}
