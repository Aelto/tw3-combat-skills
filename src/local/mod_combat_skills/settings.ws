
function mcd_isEnabled(): bool {
  return theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDmodEnabled');
}

function mcd_isInitialized(): bool {
  return theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDmodInitialized');
}

function mcd_initializeSettings() {
  theGame
    .GetInGameConfigWrapper()
    .ApplyGroupPreset('MCDgeneral', 0);

  theGame.SaveUserSettings();
}

function mcd_getPhysicalSKillStaminaCostMultiplier(): float {
  return StringToFloat(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDphysicalSkillStaminaCostMultiplier')
  );
}

function mcd_getSidestepSKillStaminaCostMultiplier(): float {
  return StringToFloat(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDsidestepSkillStaminaCostMultiplier')
  );
}

function mcd_getPhysicalSKillStaminaCostType(): MCD_StaminaCostType {
  return StringToInt(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDphysicalSkillStaminaCostType')
  );
}

function mcd_getSidestepSKillStaminaCostType(): MCD_StaminaCostType {
  return StringToInt(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDsidestepSkillStaminaCostType')
  );
}

function mcd_getPhysicalSkillCanConsumeAdrenaline(): bool {
  return theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDphysicalSkillCanConsumeAdrenaline');
}

function mcd_getPhysicalSkillCanMiss(): bool {
  return theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDphysicalSkillCanMiss');
}

function mcd_getSidestepInvulnerabilityStart(): float {
  return StringToFloat(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDsidestepInvulnerabilityStart')
  ) / 1000;
}

function mcd_getSidestepInvulnerabilityDuration(): float {
  return StringToFloat(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDsidestepInvulnerabilityDuration')
  ) / 1000;
}

function mcd_getShortDodgeMaximumDistance(): float {
  return StringToFloat(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDshortDodgeMaximumDistance')
  );
}

function mcd_getKickBind(): MCD_SkillBind {
  return StringToInt(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDkickBind')
  );
}

function mcd_getShoulderBind(): MCD_SkillBind {
  return StringToInt(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDshoulderBind')
  );
}

function mcd_getSidestepBind(): MCD_SkillBind {
  return StringToInt(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDsidestepBind')
  );
}

function mcd_getShortDodgeBind(): MCD_ShortDodgeBind {
  return StringToInt(
    theGame
    .GetInGameConfigWrapper()
    .GetVarValue('MCDgeneral', 'MCDshortDodgeBind')
  );
}