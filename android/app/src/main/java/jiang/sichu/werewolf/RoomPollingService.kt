package jiang.sichu.werewolf

import jiang.sichu.werewolf.proto.GameServiceGrpc
import jiang.sichu.werewolf.proto.Werewolf
import jiang.sichu.werewolf.proto.Werewolf.Game
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
        fun onSeatsChanged(seats: List<Werewolf.Seat>)
        fun onGameStateChanged(previousState: Game.State, currentState: Game.State)
    }

    private var executor: ScheduledExecutorService? = null
    private var taskFuture: Future<*>? = null
    private var seats: List<Werewolf.Seat> = listOf()
    private var currentState: Game.State = Game.State.UNKNOWN

    fun init() {
        executor = Executors.newSingleThreadScheduledExecutor()
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
        val request = Werewolf.GetRoomRequest.newBuilder().setRoomId(roomId).build()
        val room = gameService.getRoom(request).room
        if (seats != room.seatsList) {
            listener.onSeatsChanged(room.seatsList)
            seats = room.seatsList
        }
        if (currentState != room.game.state) {
            listener.onGameStateChanged(currentState, room.game.state)
            currentState = room.game.state
        }
    }
}