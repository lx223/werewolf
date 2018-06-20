package jiang.sichu.werewolf

import android.os.Bundle
import android.support.annotation.WorkerThread
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import jiang.sichu.werewolf.proto.Werewolf.*
import jiang.sichu.werewolf.ui.SquareImageView
import kotlinx.android.synthetic.main.fragment_room.view.*

private const val ARG_ROOM_ID = "roomId"
private const val ARG_USER_ID = "userId"
private const val COLUMN_COUNT = 4
private const val COLOR_RES_MY_SEAT = android.R.color.holo_green_dark
private const val COLOR_RES_OTHER_SEATS = android.R.color.darker_gray

class RoomFragment : GameFragment() {

    companion object {
        @JvmStatic
        fun newInstance(roomId: String, userId: String) =
                RoomFragment().apply {
                    arguments = Bundle().apply {
                        putString(ARG_ROOM_ID, roomId)
                        putString(ARG_USER_ID, userId)
                    }
                }
    }

    private var roomId: String? = null
    private var userId: String? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        roomId = arguments.getString(ARG_ROOM_ID)
        userId = arguments.getString(ARG_USER_ID)
        val view = inflater.inflate(R.layout.fragment_room, container, false)
        view.grid_seats.numColumns = COLUMN_COUNT
        view.grid_seats.adapter = SeatAdapter()
        return view
    }

    override fun onResume() {
        super.onResume()

        // TODO: update seats periodically
        executor?.execute { getSeatsAndUpdateView() }
    }

    private fun takeSeat(seatId: String) {
        executor?.execute {
            val request = TakeSeatRequest.newBuilder().setSeatId(seatId).setUserId(userId).build()
            gameService?.takeSeat(request)
            getSeatsAndUpdateView()
        }
    }

    @WorkerThread
    private fun getSeatsAndUpdateView() {
        val request = GetRoomRequest.newBuilder().setRoomId(roomId).build()
        val seats = gameService?.getRoom(request)!!.room.seatsList
        activity?.runOnUiThread {
            (view?.grid_seats?.adapter as SeatAdapter).setSeats(seats)
            seats.firstOrNull { seat -> seat.user.id == userId }?.role
                    .let { role -> view.image_role_card.setRole(role) }
        }
    }

    inner class SeatAdapter : BaseAdapter() {
        private var seats: List<Seat> = arrayListOf()

        fun setSeats(seats: List<Seat>) {
            this.seats = seats
            notifyDataSetChanged()
        }

        override fun getCount() = seats.size

        override fun getItem(position: Int) = seats[position]

        override fun getItemId(position: Int) = position.toLong()

        override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
            val colorRes = if (getItem(position).user.id == userId) COLOR_RES_MY_SEAT else COLOR_RES_OTHER_SEATS
            return SquareImageView(context, null).apply {
                setBackgroundColor(resources.getColor(colorRes))
                setOnClickListener { takeSeat(getItem(position).id) }
            }
        }
    }
}
