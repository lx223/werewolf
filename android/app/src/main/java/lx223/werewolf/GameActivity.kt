package lx223.werewolf

import android.content.Context
import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import io.grpc.ManagedChannel
import io.grpc.ManagedChannelBuilder
import lx223.werewolf.model.RoomInfo
import lx223.werewolf.proto.GameServiceGrpc

private const val HOST = "35.229.117.155"
private const val PORT = 21806
private const val PREF_ROOM_ID = "room_id"
private const val PREF_USER_ID = "user_id"

class GameActivity : FragmentActivity(), GameEventListener {

    var gameService: GameServiceGrpc.GameServiceFutureStub? = null
    var userId: String? = null
    var roomId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_menu)
        gameService = GameServiceGrpc.newFutureStub(
                ManagedChannelBuilder.forAddress(HOST, PORT).usePlaintext().build())

        val menuFragment = MenuFragment()
        getPreviousRoomInfo()?.let {
            menuFragment.arguments = Bundle().apply { putParcelable(ARG_PREV_ROOM_INFO, it) }
        }
        showFragment(menuFragment)
    }

    override fun onDestroy() {
        super.onDestroy()
        (gameService?.channel as ManagedChannel).shutdown()
        gameService = null
    }

    override fun onCreateRoomSuccess(roomId: String, userId: String) {
        this.userId = userId
        this.roomId = roomId
        saveRoomInfo(RoomInfo(roomId, userId))
        showFragment(GameConfigFragment())
    }

    override fun onJoinRoomSuccess(roomId: String, userId: String) {
        this.userId = userId
        this.roomId = roomId
        saveRoomInfo(RoomInfo(roomId, userId))
        showFragment(RoomFragment())
    }

    override fun onUpdateGameConfigSuccess() {
        showFragment(HostRoomFragment())
    }

    override fun onCheckRoleButtonClick() {
        showFragment(RoleFragment())
    }

    private fun showFragment(fragment: Fragment) {
        runOnUiThread {
            supportFragmentManager.beginTransaction()
                    .replace(R.id.fragment_container, fragment)
                    .apply { addToBackStack(null) }
                    .commit()
        }
    }

    private fun saveRoomInfo(roomInfo: RoomInfo) {
        getPreferences(Context.MODE_PRIVATE).edit().apply {
            putString(PREF_ROOM_ID, roomInfo.roomId)
            putString(PREF_USER_ID, roomInfo.userId)
            apply()
        }
    }

    private fun getPreviousRoomInfo(): RoomInfo? {
        val sharedPrefs = getPreferences(Context.MODE_PRIVATE)
        val roomId = sharedPrefs.getString(PREF_ROOM_ID, null)
        val userId = sharedPrefs.getString(PREF_USER_ID, null)
        return if (roomId == null && userId == null) null else RoomInfo(roomId!!, userId!!)
    }
}
