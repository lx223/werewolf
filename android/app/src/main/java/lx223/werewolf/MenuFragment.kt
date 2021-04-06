package lx223.werewolf

import android.app.AlertDialog
import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import lx223.werewolf.databinding.DialogJoinRoomBinding
import lx223.werewolf.databinding.FragmentMenuBinding
import lx223.werewolf.model.RoomInfo
import lx223.werewolf.proto.Werewolf.CreateAndJoinRoomRequest
import lx223.werewolf.proto.Werewolf.JoinRoomRequest

const val ARG_PREV_ROOM_INFO = "prev_room_info"

class MenuFragment : BaseFragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val binding = FragmentMenuBinding.inflate(inflater, container, false)
        binding.btnCreateRoom.setOnClickListener { createAndJoinRoom() }
        binding.btnJoinRoom.setOnClickListener { showJoinRoomDialog() }
        arguments?.getParcelable<RoomInfo>(ARG_PREV_ROOM_INFO)?.let {
            initJoinPrevRoomBtn(binding.btnJoinPrevRoom, it)
        }
        return binding.root
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
        val binding = DialogJoinRoomBinding.inflate(LayoutInflater.from(context))
        AlertDialog.Builder(context)
                .setTitle(R.string.dialog_title_join_room)
                .setView(binding.root)
                .setPositiveButton(
                        R.string.btn_label_confirm
                ) { _, _ -> joinRoom(binding.roomIdInput.text.toString(), null) }
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
