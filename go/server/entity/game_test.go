package entity

import (
	"testing"

	werewolf "github.com/lx223/werewolf-assistant/generated"

	"github.com/stretchr/testify/assert"
)

func TestComputePossibleStates(t *testing.T) {
	inputs := [][]werewolf.Role{
		{
			werewolf.Role_VILLAGER,
		},
		{
			werewolf.Role_VILLAGER,
			werewolf.Role_WITCH,
			werewolf.Role_IDIOT,
		},
		{
			werewolf.Role_VILLAGER,
			werewolf.Role_VILLAGER,
			werewolf.Role_VILLAGER,
			werewolf.Role_VILLAGER,
			werewolf.Role_WITCH,
			werewolf.Role_SEER,
			werewolf.Role_GUARDIAN,
			werewolf.Role_HUNTER,
			werewolf.Role_HALF_BLOOD,
			werewolf.Role_ORPHAN,
			werewolf.Role_WEREWOLF,
			werewolf.Role_WEREWOLF,
			werewolf.Role_WEREWOLF,
			werewolf.Role_WHITE_WEREWOLF,
		},
	}
	expectedOutputs := [][]werewolf.Game_State{
		{
			werewolf.Game_SHERIFF_ELECTION,
		},
		{
			werewolf.Game_WITCH_AWAKE,
			werewolf.Game_SHERIFF_ELECTION,
		},
		{
			werewolf.Game_ORPHAN_AWAKE,
			werewolf.Game_HALF_BLOOD_AWAKE,
			werewolf.Game_GUARDIAN_AWAKE,
			werewolf.Game_WEREWOLF_AWAKE,
			werewolf.Game_WITCH_AWAKE,
			werewolf.Game_SEER_AWAKE,
			werewolf.Game_HUNTER_AWAKE,
			werewolf.Game_SHERIFF_ELECTION,
		},
	}

	for i, input := range inputs {
		states := computePossibleStates(input)

		assert.Equal(t, expectedOutputs[i], states)
	}
}

func TestIsWerewolfKillingSuccessful_NoWolfKilling_False(t *testing.T) {
	g := &Game{}

	r := g.isWerewolfKillingSuccessful()

	assert.False(t, r)
}

func TestIsWerewolfKillingSuccessful_WitchCure_False(t *testing.T) {
	g := &Game{
		WerewolfKillSeatId: "1",
		WitchCureSeatId:    "1",
	}

	r := g.isWerewolfKillingSuccessful()

	assert.False(t, r)
}

func TestIsWerewolfKillingSuccessful_CorrectGuarding_False(t *testing.T) {
	g := &Game{
		WerewolfKillSeatId: "1",
		GuardSeatId:        "1",
	}

	r := g.isWerewolfKillingSuccessful()

	assert.False(t, r)
}

func TestIsWerewolfKillingSuccessful_NoGuardOrCure_True(t *testing.T) {
	g := &Game{
		WerewolfKillSeatId: "1",
	}

	r := g.isWerewolfKillingSuccessful()

	assert.True(t, r)
}

func TestIsWerewolfKillingSuccessful_GuardAndCure_True(t *testing.T) {
	g := &Game{
		WerewolfKillSeatId: "1",
		GuardSeatId:        "1",
		WitchCureSeatId:    "1",
	}

	r := g.isWerewolfKillingSuccessful()

	assert.True(t, r)
}
