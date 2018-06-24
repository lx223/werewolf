package jiang.sichu.werewolf

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import jiang.sichu.werewolf.proto.Werewolf.*
import kotlinx.android.synthetic.main.fragment_room.view.*

class RoomFragment : BaseFragment(), RoomPollingService.Listener {

    private var seatAdapter: SeatAdapter? = null
    private var roomPollingService: RoomPollingService? = null
    private var audioManager: AudioManager? = null

    override fun onCreateView(inflater: LayoutInflater,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {

        val view = inflater.inflate(R.layout.fragment_room, container, false)
        seatAdapter = SeatAdapter(context, activity?.userId, this::takeSeat)
        view.grid_seats.adapter = seatAdapter
        view.btn_check_role.setOnClickListener { activity?.onCheckRoleButtonClick() }
        roomPollingService = RoomPollingService(activity?.roomId!!, this, gameService!!).apply { init() }
        audioManager = AudioManager(context)

        if (activity!!.isHost) {
            view.btn_start_game.visibility = View.VISIBLE
            view.btn_start_game.setOnClickListener { startGame() }
        }

        return view
    }

    override fun onResume() {
        super.onResume()
        roomPollingService?.start()
    }

    override fun onPause() {
        super.onPause()
        roomPollingService?.stop()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        seatAdapter = null
        roomPollingService?.shutdown()
        roomPollingService = null
        audioManager?.shutdown()
        audioManager = null
    }

    override fun onSeatsChanged(seats: List<Seat>) {
        runOnUiThread {
            seatAdapter?.setSeats(seats)
            val isSeated = seats.any { seat -> seat.user.id == activity?.userId }
            view.btn_check_role.visibility = if (isSeated) View.VISIBLE else View.GONE
        }
    }

    override fun onGameStateChanged(previousState: Game.State, currentState: Game.State) {
        runOnUiThread {
            audioManager?.enqueue(previousState, AudioManager.Type.END)
            audioManager?.enqueue(currentState, AudioManager.Type.START)
        }
    }

    private fun takeSeat(seatId: String) {
        executor?.execute {
            val request = TakeSeatRequest.newBuilder().setSeatId(seatId).setUserId(activity?.userId).build()
            gameService?.takeSeat(request)
        }
    }

    private fun startGame() {
        executor?.execute {
            val request = StartGameRequest.newBuilder().setRoomId(activity?.roomId).build()
            gameService?.startGame(request)
        }
    }
}
