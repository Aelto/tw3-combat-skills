@context(
  file(game/player/r4Player.ws)
  at(class CR4Player)
)

@insert(
  note("make the FindTarget player function public for Combatskills")
  select(protected function FindTarget)
)
// modCombatSkill - BEGIN & END
public function FindTarget