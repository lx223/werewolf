package jiang.sichu.werewolf

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import jiang.sichu.werewolf.proto.Werewolf.Seat
import jiang.sichu.werewolf.ui.SquareImageView

private const val COLOR_RES_MY_SEAT = android.R.color.holo_green_dark
private const val COLOR_RES_OTHER_SEATS = android.R.color.darker_gray

class SeatAdapter(private val context: Context,
                  private val userId: String?,
                  private val takeSeatFunc: (String) -> Unit) : BaseAdapter() {
        private var seats: List<Seat> = arrayListOf()

        fun setSeats(seats: List<Seat>) {
            this.seats = seats
            notifyDataSetChanged()
        }

        override fun getCount() = seats.size

        override fun getItem(position: Int) = seats[position]

        override fun getItemId(position: Int) = position.toLong()

        override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
            val isMySeat = getItem(position).user.id == userId
            val colorRes = if (isMySeat) COLOR_RES_MY_SEAT else COLOR_RES_OTHER_SEATS
            return SquareImageView(context, null).apply {
                setBackgroundColor(context.resources.getColor(colorRes))
                setOnClickListener { takeSeatFunc(getItem(position).id) }
            }
        }
    }
