package entity

import (
	"server/generated"
	"testing"

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
			werewolf.Role_WEREWOLF,
			werewolf.Role_WEREWOLF,
			werewolf.Role_WEREWOLF,
			werewolf.Role_WHITE_WEREWOLF,
		},
	}
	expectedOutputs := [][]werewolf.Game_State{
		{
			werewolf.Game_DARKNESS_FALLS,
			werewolf.Game_SHERIFF_ELECTION,
		},
		{
			werewolf.Game_DARKNESS_FALLS,
			werewolf.Game_WITCH_AWAKE,
			werewolf.Game_SHERIFF_ELECTION,
		},
		{
			werewolf.Game_DARKNESS_FALLS,
			werewolf.Game_HALF_BLOOD_AWAKE,
			werewolf.Game_GUARDIAN_AWAKE,
			werewolf.Game_WEREWOLF_AWAKE,
			werewolf.Game_WITCH_AWAKE,
			werewolf.Game_SEER_AWAKE,
			werewolf.Game_HUNTER_AWAKE,
			werewolf.Game_WHITE_WEREWOLF_AWAKE,
			werewolf.Game_SHERIFF_ELECTION,
		},
	}

	for i, input := range inputs {
		states := computePossibleStates(input)

		assert.Equal(t, expectedOutputs[i], states)
	}
}
