package lx223.werewolf

import android.support.annotation.WorkerThread
import lx223.werewolf.proto.GameServiceGrpc
import lx223.werewolf.proto.Werewolf.*
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

private const val POLLING_PERIOD_SEC = 1L

// TODO: refactor to use a real service.
class RoomService(private val roomId: String,
                  private val listener: Listener,
                  private val gameService: GameServiceGrpc.GameServiceBlockingStub) {

    interface Listener {
        fun onSeatsChanged(seats: List<Seat>)
        fun onGameStateChanged(previousState: Game.State, currentState: Game.State)
    }

    private var executor: ScheduledExecutorService? = null
    private var taskFuture: Future<*>? = null
    private var room = Room.getDefaultInstance()

    fun init() {
        executor = Executors.newSingleThreadScheduledExecutor()
        room = Room.newBuilder().setGame(Game.newBuilder().setState(Game.State.UNKNOWN)).build()
    }

    fun start() {
        taskFuture = executor!!.scheduleAtFixedRate(
                { fetchRoomAndNotifyListenerIfChanged() },
                /*initialDelay=*/ 0,
                POLLING_PERIOD_SEC,
                TimeUnit.SECONDS
        )
    }

    fun stop() {
        taskFuture?.cancel(true)
        taskFuture = null
    }

    fun shutdown() {
        executor?.shutdown()
        executor = null
    }

    @WorkerThread
    fun getRoom() = room ?: fetchRoom()

    @WorkerThread
    private fun fetchRoom() = gameService.getRoom(GetRoomRequest.newBuilder().setRoomId(roomId).build()).room!!

    private fun fetchRoomAndNotifyListenerIfChanged() {
        val newRoom = fetchRoom()
        if (newRoom.seatsList != room.seatsList) {
            listener.onSeatsChanged(newRoom.seatsList)
        }
        if (newRoom.game.state != room.game.state) {
            listener.onGameStateChanged(room.game.state, newRoom.game.state)
        }
        room = newRoom
    }
}
