package lx223.werewolf

import android.app.AlertDialog
import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import lx223.werewolf.model.RoomInfo
import lx223.werewolf.proto.Werewolf.CreateAndJoinRoomRequest
import lx223.werewolf.proto.Werewolf.JoinRoomRequest
import kotlinx.android.synthetic.main.dialog_join_room.*
import kotlinx.android.synthetic.main.fragment_menu.view.*

const val ARG_PREV_ROOM_INFO = "prev_room_info"

class MenuFragment : BaseFragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_menu, container, false)
        view.btn_create_room.setOnClickListener { createAndJoinRoom() }
        view.btn_join_room.setOnClickListener { showJoinRoomDialog() }
        arguments?.getParcelable<RoomInfo>(ARG_PREV_ROOM_INFO)?.let {
            initJoinPrevRoomBtn(view.btn_join_prev_room, it)
        }
        return view
    }

    private fun initJoinPrevRoomBtn(joinPrevRoomBtn: Button, prevRoomInfo: RoomInfo) {
        joinPrevRoomBtn.apply {
            visibility = View.VISIBLE
            setOnClickListener { joinRoom(prevRoomInfo.roomId, prevRoomInfo.userId) }
        }
    }

    private fun createAndJoinRoom() {
        executor?.execute {
            val request = CreateAndJoinRoomRequest.newBuilder().build()
            val response = gameService?.createAndJoinRoom(request)!!
            activity?.onCreateRoomSuccess(response.roomId, response.userId)
        }
    }

    private fun showJoinRoomDialog() {
        AlertDialog.Builder(context)
                .setTitle(R.string.dialog_title_join_room)
                .setView(R.layout.dialog_join_room)
                .setPositiveButton(
                        R.string.btn_label_confirm
                ) { dialog, _ -> joinRoom((dialog as Dialog).room_id_input.text.toString(), null) }
                .show()
    }

    private fun joinRoom(roomId: String, userId: String?) {
        executor?.execute {
            val request = JoinRoomRequest.newBuilder().setRoomId(roomId).setUserId(userId).build()
            val response = gameService?.joinRoom(request)!!
            activity?.onJoinRoomSuccess(roomId, response.userId)
        }
    }
}
