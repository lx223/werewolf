package util

import "strings"

func IsEmptyOrWhiteSpace(s string) bool {
	return len(strings.TrimSpace(s)) == 0
}
