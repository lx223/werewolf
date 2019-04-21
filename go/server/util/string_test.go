package util

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIsEmptyOrWhileSpace(t *testing.T) {
	for k, v := range map[string]bool{
		" ":  true,
		"":   true,
		"s":  false,
		"s ": false,
		" s": false,
	} {
		assert.Equal(t, v, IsEmptyOrWhiteSpace(k))
	}
}
