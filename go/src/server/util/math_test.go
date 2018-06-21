package util

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMin(t *testing.T) {
	r := Min(1, 5)

	assert.Equal(t, r, 1)
}
