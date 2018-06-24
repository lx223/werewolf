package jiang.sichu.werewolf

import jiang.sichu.werewolf.proto.GameServiceGrpc
import jiang.sichu.werewolf.proto.Werewolf.*
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

private const val POLLING_PERIOD_SEC = 1L

// TODO: refactor to use a real service.
class RoomPollingService(private val roomId: String,
                         private val listener: Listener,
                         private val gameService: GameServiceGrpc.GameServiceBlockingStub) {

    interface Listener {
        fun onSeatsChanged(seats: List<Seat>)
        fun onGameStateChanged(previousState: Game.State, currentState: Game.State)
    }

    private var executor: ScheduledExecutorService? = null
    private var taskFuture: Future<*>? = null
    private var room = Room.getDefaultInstance()

    fun getRoom() = room

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

    private fun fetchRoomAndNotifyListenerIfChanged() {
        val request = GetRoomRequest.newBuilder().setRoomId(roomId).build()
        val newRoom = gameService.getRoom(request).room
        if (newRoom.seatsList != room.seatsList) {
            listener.onSeatsChanged(newRoom.seatsList)
        }
        if (newRoom.game.state != room.game.state) {
            listener.onGameStateChanged(newRoom.game.state, room.game.state)
        }
        room = newRoom
    }
}
