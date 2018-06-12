package jiang.sichu.werewolf

import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.os.Bundle
import io.grpc.ManagedChannel
import io.grpc.ManagedChannelBuilder
import jiang.sichu.werewolf.proto.room.RoomOuterClass.CreateRoomRequest
import jiang.sichu.werewolf.proto.room.RoomOuterClass.JoinRoomRequest
import jiang.sichu.werewolf.proto.room.RoomServiceGrpc
import kotlinx.android.synthetic.main.activity_menu.*
import kotlinx.android.synthetic.main.dialog_join_room.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class MenuActivity : Activity() {

    private val host = "10.0.2.2"
    private val port = 8080
    private val rpcTimeoutSec = 5L

    private var channel: ManagedChannel? = null
    private var executor: ExecutorService? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_menu)
        channel = ManagedChannelBuilder.forAddress(host, port).usePlaintext().build()
        executor = Executors.newSingleThreadExecutor()
        btn_create_room.setOnClickListener({ createRoom() })
        btn_join_room.setOnClickListener({ showJoinRoomDialog() })
    }

    override fun onDestroy() {
        super.onDestroy()
        channel?.shutdown()
        channel = null
        executor?.shutdown()
        executor = null
    }

    private fun showJoinRoomDialog() {
        AlertDialog.Builder(this)
                .setTitle(R.string.dialog_title_join_room)
                .setView(R.layout.dialog_join_room)
                .setPositiveButton(
                        R.string.btn_label_confirm,
                        { dialog, _ -> joinRoom((dialog as Dialog).room_id_input.text.toString().toInt()) })
                .show()
    }

    private fun joinRoom(roomId: Int) {
        executor?.execute {
            val roomService = RoomServiceGrpc.newFutureStub(channel)
            val joinRoomRequest = JoinRoomRequest.newBuilder().setRoomId(roomId).build()
            val userId = roomService.joinRoom(joinRoomRequest)[rpcTimeoutSec, TimeUnit.SECONDS].userId
            runOnUiThread { AlertDialog.Builder(this).setMessage("Joined room $roomId!\nUser ID: $userId").show() }
        }
    }

    private fun createRoom() {
        executor?.execute {
            val roomService = RoomServiceGrpc.newFutureStub(channel)
            val createRoomRequest = CreateRoomRequest.newBuilder().build()
            val roomId = roomService.createRoom(createRoomRequest)[rpcTimeoutSec, TimeUnit.SECONDS].roomId
            runOnUiThread { AlertDialog.Builder(this).setMessage("Created room: $roomId").show() }
        }
    }
}
