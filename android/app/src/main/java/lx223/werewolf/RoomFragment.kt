package lx223.werewolf

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.snackbar.Snackbar
import com.google.android.material.snackbar.Snackbar.*
import lx223.werewolf.proto.Werewolf.*
import lx223.werewolf.proto.Werewolf.Game.State.*
import lx223.werewolf.proto.Werewolf.Role.*
import lx223.werewolf.databinding.FragmentRoomBinding

class RoomFragment : BaseFragment(), RoomService.Listener {

    private var _binding: FragmentRoomBinding? = null
    private val binding get() = _binding!!

    private var seatAdapter: SeatAdapter? = null
    private var roomService: RoomService? = null
    // TODO: move audio manager to activity to avoid interruption on fragment transactions
    private var audioManager: AudioManager? = null

    override fun onCreateView(inflater: LayoutInflater,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        _binding = FragmentRoomBinding.inflate(inflater, container, false)
        binding.title.text = getString(R.string.fragment_room_title_room_id, activity?.roomId)

        seatAdapter = SeatAdapter(context, activity!!.userId)
                .apply { setTakeSeatListener(this@RoomFragment::takeSeat) }
        binding.gridSeats.adapter = seatAdapter
        binding.btnCheckRole.setOnClickListener { activity?.onCheckRoleButtonClick() }
        binding.btnTakeAction.setOnClickListener { takeAction() }

        roomService = RoomService(activity?.roomId!!, this, gameService!!).apply { init() }

        if (activity!!.isHost) {
            binding.btnReassignRoles.apply {
                visibility = View.VISIBLE
                setOnClickListener { showReassignRolesDialog() }
            }
            binding.btnStartGame.apply {
                visibility = View.VISIBLE
                isEnabled = false
                setOnClickListener {
                    startGame()
                    isEnabled = false
                }
            }
            binding.btnResult.apply {
                visibility = View.GONE
                setOnClickListener { showLastNightResult() }
            }
        }

        return binding.root
    }

    override fun onResume() {
        super.onResume()
        roomService?.start()
    }

    override fun onPause() {
        super.onPause()
        roomService?.stop()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        seatAdapter = null
        roomService?.shutdown()
        roomService = null
        audioManager?.reset()
        audioManager = null
    }

    override fun onSeatsChanged(seats: List<Seat>) {
        runOnUiThread {
            seatAdapter?.setSeats(seats)
            val isSeated = seats.any { it.user.id == activity?.userId }
            if (isSeated) {
                binding.btnCheckRole.visibility = View.VISIBLE
                binding.btnTakeAction.visibility = View.VISIBLE
            }
            if (seats.all { it.hasUser() }) {
                binding.btnStartGame.isEnabled = true
            }
        }
    }

    override fun onGameStateChanged(previousState: Game.State, currentState: Game.State) {
        if (previousState == Game.State.UNKNOWN) {
            seatAdapter?.clearTakeSeatListener()
        }

        if (!activity!!.isHost) {
            return
        }

        audioManager?.apply {
            enqueue(previousState, AudioManager.Type.END)
            enqueue(currentState, AudioManager.Type.START)
        }
        if (currentState == SHERIFF_ELECTION) {
            runOnUiThread {
                binding.btnStartGame.visibility = View.GONE
                binding.btnResult.visibility = View.VISIBLE
            }
        }
    }

    private fun takeSeat(seatId: String) {
        executor?.execute {
            val request = TakeSeatRequest.newBuilder().setSeatId(seatId).setUserId(activity?.userId).build()
            gameService?.takeSeat(request)
        }
    }

    private fun showReassignRolesDialog() {
        AlertDialog.Builder(context)
                .setMessage(R.string.dialog_confirm_reassign_roles)
                .setPositiveButton(R.string.btn_label_confirm) { _, _ -> reassignRoles() }
                .show()
    }

    private fun reassignRoles() {
        executor?.execute {
            val request = ReassignRolesRequest.newBuilder().setRoomId(activity?.roomId).build()
            gameService?.reassignRoles(request)
            runOnUiThread {
                audioManager?.reset()
                audioManager = null
                binding.btnResult.visibility = View.GONE
                binding.btnStartGame.apply {
                    isEnabled = true
                    visibility = View.VISIBLE
                }
            }
        }
    }

    private fun startGame() {
        executor?.execute {
            val request = StartGameRequest.newBuilder().setRoomId(activity?.roomId).build()
            gameService?.startGame(request)
            runOnUiThread { audioManager = AudioManager(context) }
        }
    }

    private fun showLastNightResult() {
        val resultStr = getReadableDeadPlayersString(roomService!!.getRoom())
        AlertDialog.Builder(context).setMessage(resultStr).show()
    }

    private fun getReadableDeadPlayersString(room: Room): String {
        val killedSeatIds = room.game.killedSeatIdsList
        return if (killedSeatIds.isEmpty()) getString(R.string.dialog_result_no_one_died)
        else killedSeatIds.map { seatId -> room.seatsList.indexOfFirst { it.id == seatId } + 1 }
                .sorted()
                .joinToString(prefix = getString(R.string.dialog_result_prefix))
    }

    private fun takeAction() {
        val myRole = roomService!!.getRoom().seatsList.first { it.user.id == activity?.userId }.role
        if (!canTakeAction(myRole)) {
            showNoActionSnackbar()
            return
        }

        when (myRole) {
            ORPHAN -> throw NotImplementedError()
            HALF_BLOOD -> takeHalfBloodAction()
            GUARDIAN -> takeGuardianAction()
            WEREWOLF -> takeWerewolfAction()
            WITCH -> takeWitchAction()
            SEER -> takeSeerAction()
            HUNTER -> takeHunterAction()
            else -> showNoActionSnackbar()
        }
    }

    private fun canTakeAction(role: Role): Boolean {
        val gameState = roomService!!.getRoom().game.state
        return when (role) {
            ORPHAN -> throw NotImplementedError()
            HALF_BLOOD -> gameState == HALF_BLOOD_AWAKE
            GUARDIAN -> gameState == GUARDIAN_AWAKE
            WEREWOLF -> gameState == WEREWOLF_AWAKE
            WITCH -> gameState == WITCH_AWAKE
            SEER -> gameState == SEER_AWAKE
            HUNTER -> gameState == HUNTER_AWAKE
            else -> false
        }
    }

    private fun showNoActionSnackbar() {
        Snackbar.make(view, R.string.snackbar_no_action, LENGTH_SHORT).show()
    }

    private fun showActionSucceededSnackbar() {
        Snackbar.make(view, R.string.snackbar_action_succeeded, LENGTH_SHORT).show()
    }

    private fun takeHalfBloodAction() {
        val snackbar = Snackbar.make(view, R.string.snackbar_half_blood_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            executor?.execute {
                val halfBloodAction = TakeActionRequest.HalfBloodAction.newBuilder().setSeatId(seatId)
                val request = createTakeActionRequestBuilder().setHalfBlood(halfBloodAction).build()
                gameService!!.takeAction(request)
                runOnUiThread {
                    snackbar.dismiss()
                    showActionSucceededSnackbar()
                }
            }
        }
    }

    private fun takeGuardianAction() {
        val snackbar = Snackbar.make(view, R.string.snackbar_guardian_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            executor?.execute {
                val guardianAction = TakeActionRequest.GuardAction.newBuilder().setSeatId(seatId)
                val request = createTakeActionRequestBuilder().setGuard(guardianAction).build()
                gameService!!.takeAction(request)
                runOnUiThread {
                    snackbar.dismiss()
                    showActionSucceededSnackbar()
                }
            }
        }
    }

    private fun takeWerewolfAction() {
        val snackbar = Snackbar.make(view, R.string.snackbar_werewolf_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            executor?.execute {
                val werewolfAction = TakeActionRequest.WerewolfAction.newBuilder().setSeatId(seatId)
                val request = createTakeActionRequestBuilder().setWerewolf(werewolfAction).build()
                gameService!!.takeAction(request)
                runOnUiThread {
                    snackbar.dismiss()
                    showActionSucceededSnackbar()
                }
            }
        }
    }

    private fun takeWitchAction() {
        val room = roomService!!.getRoom()
        val killedPlayerSeatId = room.game.killedSeatIdsList?.firstOrNull()
        val mySeatId = room.seatsList.first { it.user.id == activity?.userId }.id
        when (killedPlayerSeatId) {
            null -> showPoisonDialog(R.string.dialog_witch_poison_action_nobody_killed)
            mySeatId -> showPoisonDialog(R.string.dialog_witch_poison_action_witch_killed)
            else -> showCureDialog(killedPlayerSeatId)
        }
    }

    private fun showCureDialog(killedPlayerSeatId: String) {
        val killedPlayerSeatIndex = roomService!!.getRoom().seatsList.indexOfFirst { it.id == killedPlayerSeatId } + 1
        AlertDialog.Builder(context)
                .setMessage(getString(R.string.dialog_witch_cure_action, killedPlayerSeatIndex))
                .setPositiveButton(R.string.btn_label_yes) { _, _ -> cure(killedPlayerSeatId) }
                .setNegativeButton(R.string.btn_label_no) { _, _ -> showPoisonDialog(R.string.dialog_witch_poison_action) }
                .show()
    }

    private fun showPoisonDialog(messageResId: Int) {
        AlertDialog.Builder(context)
                .setMessage(messageResId)
                .setPositiveButton(R.string.btn_label_yes) { _, _ -> poison() }
                .setNegativeButton(R.string.btn_label_no) { _, _ -> witchNoAction() }
                .show()
    }

    private fun witchNoAction() {
        executor?.execute {
            val witchAction = TakeActionRequest.WitchAction.newBuilder()
            gameService?.takeAction(createTakeActionRequestBuilder().setWitch(witchAction).build())
        }
    }

    private fun cure(seatId: String) {
        executor?.execute {
            val witchAction = TakeActionRequest.WitchAction.newBuilder().setCureSeatId(seatId)
            gameService?.takeAction(createTakeActionRequestBuilder().setWitch(witchAction).build())
            runOnUiThread { showActionSucceededSnackbar() }
        }
    }

    private fun poison() {
        val snackbar = Snackbar.make(view, R.string.snackbar_witch_poison_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            executor?.execute {
                val witchAction = TakeActionRequest.WitchAction.newBuilder().setPoisonSeatId(seatId)
                gameService?.takeAction(createTakeActionRequestBuilder().setWitch(witchAction).build())
                runOnUiThread {
                    snackbar.dismiss()
                    showActionSucceededSnackbar()
                }
            }
        }
    }

    private fun takeSeerAction() {
        val snackbar = Snackbar.make(view, R.string.snackbar_seer_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, oneBasedIndex ->
            executor?.execute {
                val seerAction = TakeActionRequest.SeerAction.newBuilder().setSeatId(seatId)
                val request = createTakeActionRequestBuilder().setSeer(seerAction).build()
                val seerRuling = gameService!!.takeAction(request).seer.ruling
                val seerResultResId =
                        if (seerRuling == Ruling.POSITIVE)
                            R.string.snackbar_seer_action_result_positive
                        else R.string.snackbar_seer_action_result_negative
                runOnUiThread {
                    snackbar.dismiss()
                    Snackbar.make(view, getString(seerResultResId, oneBasedIndex), LENGTH_LONG).show()
                }
            }
        }
    }

    private fun takeHunterAction() {
        executor?.execute {
            val hunterAction = TakeActionRequest.HunterAction.newBuilder()
            val request = createTakeActionRequestBuilder().setHunter(hunterAction).build()
            val hunterRuling = gameService!!.takeAction(request).hunter.ruling
            val hunterResultResId =
                    if (hunterRuling == Ruling.POSITIVE)
                        R.string.snackbar_hunter_action_result_positive
                    else R.string.snackbar_hunter_action_result_negative
            runOnUiThread {
                Snackbar.make(view, hunterResultResId, LENGTH_LONG).show()
            }
        }
    }

    private fun createTakeActionRequestBuilder(): TakeActionRequest.Builder {
        val gameId = roomService!!.getRoom().game.id
        return TakeActionRequest.newBuilder().setGameId(gameId)
    }
}
