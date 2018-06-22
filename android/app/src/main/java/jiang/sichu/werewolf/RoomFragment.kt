package jiang.sichu.werewolf

import android.os.Bundle
import android.support.annotation.WorkerThread
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import jiang.sichu.werewolf.proto.Werewolf.GetRoomRequest
import jiang.sichu.werewolf.proto.Werewolf.TakeSeatRequest
import kotlinx.android.synthetic.main.fragment_room.view.*

class RoomFragment : BaseFragment() {

    private var seatAdapter: SeatAdapter? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_room, container, false)
        seatAdapter = SeatAdapter(context, activity?.userId, this::takeSeat)
        view.grid_seats.adapter = seatAdapter
        view.btn_check_role.setOnClickListener { activity?.onCheckRoleButtonClick() }
        return view
    }

    override fun onDestroyView() {
        super.onDestroyView()
        seatAdapter = null
    }

    private fun takeSeat(seatId: String) {
        executor?.execute {
            val request = TakeSeatRequest.newBuilder().setSeatId(seatId).setUserId(activity?.userId).build()
            gameService?.takeSeat(request)
            getSeatsAndUpdateView()
        }
    }

    override fun onResume() {
        super.onResume()

        // TODO: update seats periodically
        executor?.execute { getSeatsAndUpdateView() }
    }

    @WorkerThread
    private fun getSeatsAndUpdateView() {
        val request = GetRoomRequest.newBuilder().setRoomId(activity?.roomId).build()
        val seats = gameService?.getRoom(request)!!.room.seatsList
        runOnUiThread {
            seatAdapter?.setSeats(seats)
            val isSeated = seats.any { seat -> seat.user.id == activity?.userId }
            view.btn_check_role.visibility = if (isSeated) View.VISIBLE else View.GONE
        }
    }
}
