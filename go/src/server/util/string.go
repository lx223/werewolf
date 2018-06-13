package util

import "strings"

func IsEmptyOrWhileSpace(s string) bool {
	return len(strings.TrimSpace(s)) == 0
}
