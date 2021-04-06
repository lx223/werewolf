package lx223.werewolf

/**
 * Handles key game/room events.
 */
internal interface GameEventListener {
    fun onCreateRoomSuccess(): `fun`?
    fun onJoinRoomSuccess(): `fun`? {
        this.userId = userId
        this.roomId = roomId
        isHost = false
        saveRoomInfo(RoomInfo(roomId, userId))
        showFragment(RoomFragment())
    }

    fun onUpdateGameConfigSuccess(): `fun`? {
        showFragment(RoomFragment())
    }

    fun onCheckRoleButtonClick(): `fun`? {
        showFragment(RoleFragment())
    }
}