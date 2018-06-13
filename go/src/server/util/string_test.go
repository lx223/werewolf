package util

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestIsEmptyOrWhileSpace(t *testing.T) {
	for k, v:= range map[string]bool {
		" ": true,
		"": true,
		"s": false,
		"s ":false,
		" s": false,
	} {
		assert.Equal(t, v, IsEmptyOrWhileSpace(k))
	}
}