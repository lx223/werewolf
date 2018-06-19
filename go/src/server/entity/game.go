package entity

import (
	"server/generated"
	"server/util"
)

type Game struct {
	Id      string
	Roles   []werewolf.Role
	Seats   []Seat
	State   werewolf.Game_State
	Actions []*werewolf.TakeActionRequest

	currentStateIndex int
	possibleStates    []werewolf.Game_State
}

func NewGame(roomId string, roles []werewolf.Role, seats []Seat) *Game {
	stateSequence := computePossibleStates(roles)
	return &Game{
		Id:      util.NewGameId(roomId),
		Roles:   roles,
		Seats:   seats,
		State:   stateSequence[0],
		Actions: []*werewolf.TakeActionRequest{},

		currentStateIndex: 0,
		possibleStates:    stateSequence,
	}
}

func (g *Game) AdvanceToNextState() {
	g.currentStateIndex++
	if g.currentStateIndex >= len(g.possibleStates) {
		return
	}

	g.State = g.possibleStates[g.currentStateIndex]
}

func (g *Game) ToProto() *werewolf.Game {
	if g == nil {
		return nil
	}

	return &werewolf.Game{
		Id:                g.Id,
		State:             g.State,
		DeadPlayerNumbers: g.getFirstNightResult(),
	}
}

var stateToRole = map[werewolf.Game_State]werewolf.Role{
	werewolf.Game_HALF_BLOOD_AWAKE:     werewolf.Role_HALF_BLOOD,
	werewolf.Game_GUARDIAN_AWAKE:       werewolf.Role_GUARDIAN,
	werewolf.Game_WEREWOLF_AWAKE:       werewolf.Role_WEREWOLF,
	werewolf.Game_WHITE_WEREWOLF_AWAKE: werewolf.Role_WHITE_WEREWOLF,
	werewolf.Game_WITCH_AWAKE:          werewolf.Role_WITCH,
	werewolf.Game_SEER_AWAKE:           werewolf.Role_SEER,
	werewolf.Game_HUNTER_AWAKE:         werewolf.Role_HUNTER,
}

func computePossibleStates(roles []werewolf.Role) []werewolf.Game_State {
	hasRoles := make(map[werewolf.Role]bool)
	for _, r := range roles {
		hasRoles[r] = true
	}

	var states []werewolf.Game_State
	for s := werewolf.Game_UNKNOWN; s <= werewolf.Game_SHERIFF_ELECTION; s++ {
		switch s {
		case werewolf.Game_ORPHAN_AWAKE,
			werewolf.Game_HALF_BLOOD_AWAKE,
			werewolf.Game_GUARDIAN_AWAKE,
			werewolf.Game_WEREWOLF_AWAKE,
			werewolf.Game_WITCH_AWAKE,
			werewolf.Game_SEER_AWAKE,
			werewolf.Game_HUNTER_AWAKE,
			werewolf.Game_WHITE_WEREWOLF_AWAKE:
			r, ok := stateToRole[s]
			if !ok {
				break
			}
			if hasRoles[r] {
				states = append(states, s)
			}
		case werewolf.Game_SHERIFF_ELECTION:
			states = append(states, s)
		default:
			break

		}

	}
	return states
}

func (g *Game) getFirstNightResult() []string {
	return []string{}
}
