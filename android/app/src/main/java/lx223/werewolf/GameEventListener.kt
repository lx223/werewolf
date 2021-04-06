package lx223.werewolf

/** Handles key game/room events. */
interface GameEventListener {

    fun onCreateRoomSuccess(roomId: String, userId: String)

    fun onJoinRoomSuccess(roomId: String, userId: String)

    fun onUpdateGameConfigSuccess()

    fun onCheckRoleButtonClick()
}