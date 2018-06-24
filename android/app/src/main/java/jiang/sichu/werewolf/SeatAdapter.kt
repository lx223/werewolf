package jiang.sichu.werewolf

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import jiang.sichu.werewolf.proto.Werewolf.Seat
import jiang.sichu.werewolf.ui.SquareImageView

private const val COLOR_RES_MY_SEAT = android.R.color.holo_green_dark
private const val COLOR_RES_OTHER_SEATS = android.R.color.darker_gray

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
        val isMySeat = getItem(position).user.id == userId
        val colorRes = if (isMySeat) COLOR_RES_MY_SEAT else COLOR_RES_OTHER_SEATS
        return SquareImageView(context, null).apply {
            setBackgroundColor(context.resources.getColor(colorRes))
            setOnClickListener { listener?.onSeatClicked(getItem(position).id, position + 1) }
        }
    }
}
