
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

  var manager: MCD_Manager;
  
  var manager_instantiated: bool;
  default manager_instantiated = false;

}



enum MCD_StaminaCostType {
  MCD_StaminaCostType_None = 0,
  MCD_StaminaCostType_LightAttack = 1,
  MCD_StaminaCostType_HeavyAttack = 2,
  MCD_StaminaCostType_Rend = 3,
  MCD_StaminaCostType_Dodge = 4,
  MCD_StaminaCostType_Roll = 5
}

enum MCD_SkillBind {
  MCD_SkillBind_Forward = 0,
  MCD_SkillBind_Left = 1,
  MCD_SkillBind_Backward = 2,
  MCD_SkillBind_Right = 3,
  MCD_SkillBind_ForwardOrBackward = 4,
  MCD_SkillBind_LeftOrRight = 5
}
