package jiang.sichu.werewolf

import android.app.Activity
import android.app.Fragment
import android.content.Context
import android.os.Bundle
import io.grpc.ManagedChannel
import io.grpc.ManagedChannelBuilder
import jiang.sichu.werewolf.model.RoomInfo
import jiang.sichu.werewolf.proto.GameServiceGrpc
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

private const val HOST = "35.229.117.155"
private const val PORT = 21806
private const val PREF_ROOM_ID = "room_id"
private const val PREF_USER_ID = "user_id"

class GameActivity : Activity() {

    var executor: ExecutorService? = null
    var gameService: GameServiceGrpc.GameServiceBlockingStub? = null
    var userId: String? = null
    var roomId: String? = null
    var isHost = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_menu)
        executor = Executors.newSingleThreadExecutor()
        gameService = GameServiceGrpc.newBlockingStub(
                ManagedChannelBuilder.forAddress(HOST, PORT).usePlaintext().build())

        val menuFragment = MenuFragment()
        getPreviousRoomInfo()?.let {
            menuFragment.arguments = Bundle().apply { putParcelable(ARG_PREV_ROOM_INFO, it) }
        }
        showFragment(menuFragment)
    }

    override fun onDestroy() {
        super.onDestroy()
        executor?.shutdown()
        executor = null
        (gameService?.channel as ManagedChannel).shutdown()
        gameService = null
    }

    fun onCreateRoomSuccess(roomId: String, userId: String) {
        this.userId = userId
        this.roomId = roomId
        isHost = true
        saveRoomInfo(RoomInfo(roomId, userId))
        showFragment(GameConfigFragment())
    }

    fun onJoinRoomSuccess(roomId: String, userId: String) {
        this.userId = userId
        this.roomId = roomId
        isHost = false
        saveRoomInfo(RoomInfo(roomId, userId))
        showFragment(RoomFragment())
    }

    fun onUpdateGameConfigSuccess() {
        showFragment(RoomFragment())
    }

    fun onCheckRoleButtonClick() {
        showFragment(RoleFragment())
    }

    private fun showFragment(fragment: Fragment) {
        runOnUiThread {
            fragmentManager.beginTransaction()
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

    private fun getPreviousRoomInfo() : RoomInfo? {
        val sharedPrefs = getPreferences(Context.MODE_PRIVATE)
        val roomId = sharedPrefs.getString(PREF_ROOM_ID, null)
        val userId = sharedPrefs.getString(PREF_USER_ID, null)
        return if (roomId == null && userId == null) null else RoomInfo(roomId, userId)
    }
}
