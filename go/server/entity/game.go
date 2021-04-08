package entity

import (
	"github.com/lx223/werewolf-assistant/generated"
	"github.com/lx223/werewolf-assistant/util"
)

type Game struct {
	Id                 string
	Roles              []werewolf.Role
	Seats              map[string]*Seat
	State              werewolf.Game_State
	RoleToSeat         map[werewolf.Role]*Seat
	WerewolfKillSeatId string
	WitchCureSeatId    string
	WitchPoisonSeatId  string
	GuardSeatId        string

	currentStateIndex int
	possibleStates    []werewolf.Game_State
}

func NewGame(roomId string, roles []werewolf.Role, seats map[string]*Seat) *Game {
	stateSequence := computePossibleStates(roles)
	return &Game{
		Id:         util.NewGameId(roomId),
		Roles:      roles,
		Seats:      seats,
		State:      stateSequence[0],
		RoleToSeat: computeRoleToSeatMap(seats),

		currentStateIndex: 0,
		possibleStates:    stateSequence,
	}
}

func (g *Game) AdvanceToNextState() {
	g.currentStateIndex++
	g.currentStateIndex = util.Min(g.currentStateIndex, len(g.possibleStates)-1)
	g.State = g.possibleStates[g.currentStateIndex]
}

func (g *Game) ToProto() *werewolf.Game {
	if g == nil {
		return nil
	}

	return &werewolf.Game{
		Id:            g.Id,
		State:         g.State,
		KilledSeatIds: g.getFirstNightResult(),
	}
}

var stateToRole = map[werewolf.Game_State]werewolf.Role{
	werewolf.Game_HALF_BLOOD_AWAKE: werewolf.Role_HALF_BLOOD,
	werewolf.Game_ORPHAN_AWAKE:     werewolf.Role_ORPHAN,
	werewolf.Game_GUARDIAN_AWAKE:   werewolf.Role_GUARDIAN,
	werewolf.Game_WEREWOLF_AWAKE:   werewolf.Role_WEREWOLF,
	werewolf.Game_WITCH_AWAKE:      werewolf.Role_WITCH,
	werewolf.Game_SEER_AWAKE:       werewolf.Role_SEER,
	werewolf.Game_HUNTER_AWAKE:     werewolf.Role_HUNTER,
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
			werewolf.Game_HUNTER_AWAKE:
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

func computeRoleToSeatMap(seats map[string]*Seat) map[werewolf.Role]*Seat {
	m := make(map[werewolf.Role]*Seat)
	for _, v := range seats {
		m[v.Role] = v
	}
	return m
}

func (g *Game) getFirstNightResult() []string {
	var deadPlayerSeatIds []string
	if g.isWerewolfKillingSuccessful() {
		deadPlayerSeatIds = append(deadPlayerSeatIds, g.WerewolfKillSeatId)
	}
	if !util.IsEmptyOrWhiteSpace(g.WitchPoisonSeatId) {
		deadPlayerSeatIds = append(deadPlayerSeatIds, g.WitchPoisonSeatId)
	}
	return deadPlayerSeatIds
}

func (g *Game) isWerewolfKillingSuccessful() bool {

	// werewolf did NOT kill
	if util.IsEmptyOrWhiteSpace(g.WerewolfKillSeatId) {
		return false
	}

	cured := g.WerewolfKillSeatId == g.WitchCureSeatId
	guarded := g.WerewolfKillSeatId == g.GuardSeatId
	return (!cured && !guarded) || (cured && guarded)
}

var seerActionToRuling = map[werewolf.Role]werewolf.Ruling{
	werewolf.Role_VILLAGER:       werewolf.Ruling_POSITIVE,
	werewolf.Role_SEER:           werewolf.Ruling_POSITIVE,
	werewolf.Role_WITCH:          werewolf.Ruling_POSITIVE,
	werewolf.Role_HUNTER:         werewolf.Ruling_POSITIVE,
	werewolf.Role_IDIOT:          werewolf.Ruling_POSITIVE,
	werewolf.Role_GUARDIAN:       werewolf.Ruling_POSITIVE,
	werewolf.Role_WEREWOLF:       werewolf.Ruling_NEGATIVE,
	werewolf.Role_WHITE_WEREWOLF: werewolf.Ruling_NEGATIVE,
	werewolf.Role_ORPHAN:         werewolf.Ruling_POSITIVE,
	werewolf.Role_HALF_BLOOD:     werewolf.Ruling_POSITIVE,
}

func (g *Game) SeerAction(seatId string) werewolf.Ruling {
	seat := g.Seats[seatId]
	return seerActionToRuling[seat.Role]
}

func (g *Game) WhiteWerewolfAction() werewolf.Ruling {
	seat := g.RoleToSeat[werewolf.Role_WHITE_WEREWOLF]
	if seat.Id == g.WitchPoisonSeatId {
		return werewolf.Ruling_NEGATIVE
	} else {
		return werewolf.Ruling_POSITIVE
	}
}

func (g *Game) HunterAction() werewolf.Ruling {
	seat := g.RoleToSeat[werewolf.Role_HUNTER]
	if seat.Id == g.WitchPoisonSeatId {
		return werewolf.Ruling_NEGATIVE
	} else {
		return werewolf.Ruling_POSITIVE
	}
}
