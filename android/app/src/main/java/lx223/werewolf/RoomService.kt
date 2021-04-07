package lx223.werewolf

import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.MoreExecutors.directExecutor
import lx223.werewolf.proto.GameServiceGrpc
import lx223.werewolf.proto.Werewolf.*
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

private const val POLLING_PERIOD_SEC = 1L

// TODO: refactor to use a real service.
class RoomService(
        private val roomId: String,
        private val listener: Listener,
        private val gameService: GameServiceGrpc.GameServiceFutureStub,
        private val executor: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor()) {

    interface Listener {
        fun onSeatsChanged(seats: List<Seat>)
        fun onGameStateChanged(previousState: Game.State, currentState: Game.State)
    }

    val room: Room get() = _room
    private var _room = Room.newBuilder().setGame(Game.newBuilder().setState(Game.State.UNKNOWN)).build()
    private var taskFuture: Future<*>? = null

    fun start() {
        taskFuture = executor.scheduleAtFixedRate(
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
        executor.shutdown()
    }

    private fun fetchRoomAndNotifyListenerIfChanged() {
        val request = GetRoomRequest.newBuilder().setRoomId(roomId).build()
        Futures.transform(
                gameService.getRoom(request),
                { response ->
                    val newRoom = response!!.room
                    if (newRoom.seatsList != room.seatsList) {
                        listener.onSeatsChanged(newRoom.seatsList)
                    }
                    if (newRoom.game.state != room.game.state) {
                        listener.onGameStateChanged(room.game.state, newRoom.game.state)
                    }
                    _room = newRoom
                },
                directExecutor()
        )
    }
}
