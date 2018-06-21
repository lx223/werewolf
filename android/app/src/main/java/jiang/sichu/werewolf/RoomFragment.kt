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

private const val COLUMN_COUNT = 4
private const val COLOR_RES_MY_SEAT = android.R.color.holo_green_dark
private const val COLOR_RES_OTHER_SEATS = android.R.color.darker_gray

class RoomFragment : BaseFragment() {

    private var seatAdapter: SeatAdapter? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_room, container, false)
        seatAdapter = SeatAdapter()
        view.grid_seats.numColumns = COLUMN_COUNT
        view.grid_seats.adapter = seatAdapter
        view.btn_check_role.setOnClickListener { activity?.onCheckRoleButtonClick() }
        return view
    }

    override fun onDestroyView() {
        super.onDestroyView()
        seatAdapter = null
    }

    override fun onResume() {
        super.onResume()

        // TODO: update seats periodically
        executor?.execute { getSeatsAndUpdateView() }
    }

    private fun takeSeat(seatId: String) {
        executor?.execute {
            val request = TakeSeatRequest.newBuilder().setSeatId(seatId).setUserId(activity?.userId).build()
            gameService?.takeSeat(request)
            getSeatsAndUpdateView()
        }
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
            val isMySeat = getItem(position).user.id == activity?.userId
            val colorRes = if (isMySeat) COLOR_RES_MY_SEAT else COLOR_RES_OTHER_SEATS
            return SquareImageView(context, null).apply {
                setBackgroundColor(resources.getColor(colorRes))
                setOnClickListener { takeSeat(getItem(position).id) }
            }
        }
    }
}
