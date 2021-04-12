package lx223.werewolf

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import lx223.werewolf.proto.Werewolf

/**
 * A [RoomFragment] for the game Host.
 */
class HostRoomFragment : RoomFragment() {

    // TODO: move audio manager to activity to avoid interruption on fragment transactions
    private var _audioManager: AudioManager? = null
    private val audioManager get() = _audioManager!!

    override fun onCreateView(inflater: LayoutInflater,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        val view = super.onCreateView(inflater, container, savedInstanceState)
        _audioManager = AudioManager(context!!)
        binding.hostActionBtns.visibility = View.VISIBLE
        binding.btnStartGame.isEnabled = false
        binding.btnResult.isEnabled = false
        binding.btnReassignRoles.setOnClickListener { showReassignRolesDialog() }
        binding.btnStartGame.setOnClickListener { startGame() }
        binding.btnResult.setOnClickListener { showLastNightResult() }
        return view
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _audioManager?.reset()
        _audioManager = null
    }

    override fun onSeatsChanged(seats: List<Werewolf.Seat>) {
        super.onSeatsChanged(seats)
        if (seatAdapter.allSeated()) {
            runOnUiThread {
                binding.btnStartGame.isEnabled = true
            }
        }
    }

    override fun onGameStateChanged(previousState: Werewolf.Game.State, currentState: Werewolf.Game.State) {
        super.onGameStateChanged(previousState, currentState)
        audioManager.apply {
            enqueue(previousState, AudioManager.Type.END)
            enqueue(currentState, AudioManager.Type.START)
        }
        if (currentState == Werewolf.Game.State.SHERIFF_ELECTION) {
            runOnUiThread {
                binding.btnReassignRoles.isEnabled = true
                binding.btnResult.isEnabled = true
            }
        }
    }

    private fun showReassignRolesDialog() {
        AlertDialog.Builder(context)
                .setMessage(R.string.dialog_confirm_reassign_roles)
                .setPositiveButton(R.string.btn_label_confirm) { _, _ -> reassignRoles() }
                .show()
    }

    private fun reassignRoles() {
        binding.btnReassignRoles.isEnabled = false
        val request = Werewolf.ReassignRolesRequest.newBuilder().setRoomId(activity?.roomId).build()
        addUiThreadCallback(gameService?.reassignRoles(request)) {
            audioManager.reset()
            binding.btnReassignRoles.isEnabled = true
            binding.btnStartGame.isEnabled = seatAdapter.allSeated()
            binding.btnResult.isEnabled = false
        }
    }

    private fun startGame() {
        val request = Werewolf.StartGameRequest.newBuilder().setRoomId(activity?.roomId).build()
        addUiThreadCallback(gameService?.startGame(request)) {
            binding.btnReassignRoles.isEnabled = false
            binding.btnStartGame.isEnabled = false
        }
    }

    private fun showLastNightResult() {
        AlertDialog.Builder(context).setMessage(getLastNightResultString()).show()
    }

    private fun getLastNightResultString(): String {
        val room = roomService.room
        val deadSeatIds = room.game.killedSeatIdsList
        return if (deadSeatIds.isEmpty()) getString(R.string.dialog_result_no_one_died)
        else deadSeatIds.map { seatId -> room.seatsList.indexOfFirst { it.id == seatId } + 1 }
                .sorted()
                .joinToString(prefix = getString(R.string.dialog_result_prefix))
    }
}