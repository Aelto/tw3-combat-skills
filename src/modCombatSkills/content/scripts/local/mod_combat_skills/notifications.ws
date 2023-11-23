
function displayModCombatSkillsInitializedNotification() {
  theGame
  .GetGuiManager()
  .ShowNotification(
    GetLocStringByKey("option_combatskills_initialized")
  );
}
