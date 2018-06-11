package main

import (
	"fmt"
	"server/generated/werewolf"
)

func main() {
	role := werewolf.Role_WEREWOLF
	fmt.Println(role.String())
}
