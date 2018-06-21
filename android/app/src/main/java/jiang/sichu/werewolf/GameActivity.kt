package jiang.sichu.werewolf

import android.app.Activity
import android.app.Fragment
import android.os.Bundle
import io.grpc.ManagedChannel
import io.grpc.ManagedChannelBuilder
import jiang.sichu.werewolf.proto.GameServiceGrpc
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

private const val HOST = "10.0.2.2"
private const val PORT = 8080

class GameActivity : Activity() {

    var executor: ExecutorService? = null
    var gameService: GameServiceGrpc.GameServiceBlockingStub? = null
    var userId: String? = null
    var roomId: String? = null
    var isHost: Boolean? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_menu)
        executor = Executors.newSingleThreadExecutor()
        gameService = GameServiceGrpc.newBlockingStub(
                ManagedChannelBuilder.forAddress(HOST, PORT).usePlaintext().build())

        showFragment(MenuFragment())
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
        showFragment(GameConfigFragment())
    }

    fun onJoinRoomSuccess(roomId: String, userId: String) {
        this.userId = userId
        this.roomId = roomId
        isHost = false
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
}
