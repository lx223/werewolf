package jiang.sichu.werewolf

import android.content.Context
import android.support.annotation.ColorRes
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import jiang.sichu.werewolf.proto.Werewolf.Seat
import jiang.sichu.werewolf.ui.SquareImageView

private const val COLOR_RES_EMPTY_SEAT = android.R.color.holo_green_dark
private const val COLOR_RES_TAKEN_SEAT = android.R.color.holo_orange_dark
private const val COLOR_RES_MY_SEAT = android.R.color.holo_red_light

class SeatAdapter(private val context: Context, private val userId: String?) : BaseAdapter() {

    interface OneOffOnSeatClickListener {
        fun onSeatClicked(seatId: String, oneBasedIndex: Int)
    }

    private var seats: List<Seat> = arrayListOf()
    private var listener: OneOffOnSeatClickListener? = null

    fun setSeats(seats: List<Seat>) {
        this.seats = seats
        notifyDataSetChanged()
    }

    fun setOneOffOnSeatClickListener(callback: (String, Int) -> Unit) {
        listener = object : OneOffOnSeatClickListener {
            override fun onSeatClicked(seatId: String, oneBasedIndex: Int) {
                callback(seatId, oneBasedIndex)
                listener = null
            }
        }
    }

    override fun getCount() = seats.size

    override fun getItem(position: Int) = seats[position]

    override fun getItemId(position: Int) = position.toLong()

    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
        val colorRes = getSeatColorRes(getItem(position))
        return SquareImageView(context, null).apply {
            setBackgroundColor(context.resources.getColor(colorRes))
            setOnClickListener { listener?.onSeatClicked(getItem(position).id, position + 1) }
        }
    }

    @ColorRes
    private fun getSeatColorRes(seat: Seat) =
            if (!seat.hasUser()) COLOR_RES_EMPTY_SEAT
            else if (seat.user.id == userId) COLOR_RES_MY_SEAT
            else COLOR_RES_TAKEN_SEAT
}
