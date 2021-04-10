package lx223.werewolf

import android.app.AlertDialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.google.android.material.snackbar.BaseTransientBottomBar.*
import com.google.android.material.snackbar.Snackbar
import lx223.werewolf.databinding.FragmentRoomBinding
import lx223.werewolf.proto.Werewolf.*
import lx223.werewolf.proto.Werewolf.Game.State.*
import lx223.werewolf.proto.Werewolf.Role.*

class RoomFragment : BaseFragment(), RoomService.Listener {

    private var _binding: FragmentRoomBinding? = null
    private val binding get() = _binding!!

    private var seatAdapter: SeatAdapter? = null
    private var roomService: RoomService? = null

    // TODO: move audio manager to activity to avoid interruption on fragment transactions
    private var audioManager: AudioManager? = null

    override fun onCreateView(inflater: LayoutInflater,
                              container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        _binding = FragmentRoomBinding.inflate(inflater, container, false)
        binding.title.text = getString(R.string.fragment_room_title_room_id, activity?.roomId)

        seatAdapter = SeatAdapter(context!!, activity!!.userId)
                .apply { setTakeSeatListener(this@RoomFragment::takeSeat) }
        binding.gridSeats.adapter = seatAdapter
        binding.btnCheckRole.setOnClickListener { eventListener?.onCheckRoleButtonClick() }
        binding.btnTakeAction.setOnClickListener { takeAction() }

        roomService = RoomService(activity?.roomId!!, this, gameService!!)

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
        val request = TakeSeatRequest.newBuilder().setSeatId(seatId).setUserId(activity?.userId).build()
        addUiThreadCallback(gameService?.takeSeat(request)) { /* noop */ }
    }

    private fun showReassignRolesDialog() {
        AlertDialog.Builder(context)
                .setMessage(R.string.dialog_confirm_reassign_roles)
                .setPositiveButton(R.string.btn_label_confirm) { _, _ -> reassignRoles() }
                .show()
    }

    private fun reassignRoles() {
        val request = ReassignRolesRequest.newBuilder().setRoomId(activity?.roomId).build()
        addUiThreadCallback(gameService?.reassignRoles(request)) {
            audioManager?.reset()
            audioManager = null
            binding.btnResult.visibility = View.GONE
            binding.btnStartGame.apply {
                isEnabled = true
                visibility = View.VISIBLE
            }
        }
    }

    private fun startGame() {
        val request = StartGameRequest.newBuilder().setRoomId(activity?.roomId).build()
        addUiThreadCallback(gameService?.startGame(request)) {
            audioManager = AudioManager(context!!)
        }
    }

    private fun showLastNightResult() {
        val resultStr = getReadableDeadPlayersString(roomService!!.room)
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
        val room = roomService!!.room
        val myRole = room.seatsList.first { it.user.id == activity?.userId }.role
        val gameState = room.game.state
        if (!canTakeAction(myRole, gameState)) {
            showNoActionSnackbar()
            return
        }

        when (myRole) {
            ORPHAN -> takeOrphanAction()
            HALF_BLOOD -> takeHalfBloodAction()
            GUARDIAN -> takeGuardianAction()
            WEREWOLF -> takeWerewolfAction()
            WITCH -> takeWitchAction(room)
            SEER -> takeSeerAction()
            HUNTER -> takeHunterAction()
            else -> showNoActionSnackbar()
        }
    }

    private fun canTakeAction(role: Role, gameState: Game.State): Boolean {
        return when (role) {
            ORPHAN -> gameState == ORPHAN_AWAKE
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
        Snackbar.make(view!!, R.string.snackbar_no_action, LENGTH_SHORT).show()
    }

    private fun showActionSucceededSnackbar() {
        Snackbar.make(view!!, R.string.snackbar_action_succeeded, LENGTH_SHORT).show()
    }

    private fun takeOrphanAction() {
        val snackbar = Snackbar.make(view!!, R.string.snackbar_orphan_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            val orphanAction = TakeActionRequest.OrphanAction.newBuilder().setSeatId(seatId)
            val request = createTakeActionRequestBuilder().setOrphan(orphanAction).build()
            addUiThreadCallback(gameService!!.takeAction(request)) {
                snackbar.dismiss()
                showActionSucceededSnackbar()
            }
        }
    }

    private fun takeHalfBloodAction() {
        val snackbar = Snackbar.make(view!!, R.string.snackbar_half_blood_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            val halfBloodAction = TakeActionRequest.HalfBloodAction.newBuilder().setSeatId(seatId)
            val request = createTakeActionRequestBuilder().setHalfBlood(halfBloodAction).build()
            addUiThreadCallback(gameService!!.takeAction(request)) {
                snackbar.dismiss()
                showActionSucceededSnackbar()
            }
        }
    }

    private fun takeGuardianAction() {
        val snackbar = Snackbar.make(view!!, R.string.snackbar_guardian_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            val guardianAction = TakeActionRequest.GuardAction.newBuilder().setSeatId(seatId)
            val request = createTakeActionRequestBuilder().setGuard(guardianAction).build()
            addUiThreadCallback(gameService!!.takeAction(request)) {
                snackbar.dismiss()
                showActionSucceededSnackbar()
            }
        }
    }

    private fun takeWerewolfAction() {
        val snackbar = Snackbar.make(view!!, R.string.snackbar_werewolf_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            val werewolfAction = TakeActionRequest.WerewolfAction.newBuilder().setSeatId(seatId)
            val request = createTakeActionRequestBuilder().setWerewolf(werewolfAction).build()
            addUiThreadCallback(gameService!!.takeAction(request)) {
                snackbar.dismiss()
                showActionSucceededSnackbar()
            }
        }
    }

    private fun takeWitchAction(room: Room) {
        val killedPlayerSeatId = room.game.killedSeatIdsList?.firstOrNull()
        val mySeatId = room.seatsList.first { it.user.id == activity?.userId }.id
        when (killedPlayerSeatId) {
            null -> showPoisonDialog(R.string.dialog_witch_poison_action_nobody_killed)
            mySeatId -> showPoisonDialog(R.string.dialog_witch_poison_action_witch_killed)
            else -> {
                val killedPlayerSeatIndex = 1 + room.seatsList.indexOfFirst { it.id == killedPlayerSeatId }
                showCureDialog(killedPlayerSeatId, killedPlayerSeatIndex)
            }
        }
    }

    private fun showCureDialog(killedPlayerSeatId: String, killedPlayerSeatIndex: Int) {
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
        val witchAction = TakeActionRequest.WitchAction.newBuilder()
        val request = createTakeActionRequestBuilder().setWitch(witchAction).build()
        addUiThreadCallback(gameService?.takeAction(request)) { /* noop */ }
    }

    private fun cure(seatId: String) {
        val witchAction = TakeActionRequest.WitchAction.newBuilder().setCureSeatId(seatId)
        val request = createTakeActionRequestBuilder().setWitch(witchAction).build()
        addUiThreadCallback(gameService?.takeAction(request)) {
            showActionSucceededSnackbar()
        }
    }

    private fun poison() {
        val snackbar = Snackbar.make(view!!, R.string.snackbar_witch_poison_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, _ ->
            val witchAction = TakeActionRequest.WitchAction.newBuilder().setPoisonSeatId(seatId)
            val request = createTakeActionRequestBuilder().setWitch(witchAction).build()
            addUiThreadCallback(gameService?.takeAction(request)) {
                snackbar.dismiss()
                showActionSucceededSnackbar()
            }
        }
    }

    private fun takeSeerAction() {
        val snackbar = Snackbar.make(view!!, R.string.snackbar_seer_action, LENGTH_INDEFINITE).apply { show() }
        seatAdapter?.setOneOffOnSeatClickListener { seatId, oneBasedIndex ->
            val seerAction = TakeActionRequest.SeerAction.newBuilder().setSeatId(seatId)
            val request = createTakeActionRequestBuilder().setSeer(seerAction).build()
            addUiThreadCallback(gameService?.takeAction(request)) { response ->
                val seerRuling = response.seer.ruling
                val seerResultResId =
                        if (seerRuling == Ruling.POSITIVE)
                            R.string.snackbar_seer_action_result_positive
                        else R.string.snackbar_seer_action_result_negative
                snackbar.dismiss()
                Snackbar.make(view!!, getString(seerResultResId, oneBasedIndex), LENGTH_LONG).show()
            }
        }
    }

    private fun takeHunterAction() {
        val hunterAction = TakeActionRequest.HunterAction.newBuilder()
        val request = createTakeActionRequestBuilder().setHunter(hunterAction).build()
        addUiThreadCallback(gameService?.takeAction(request)) { response ->
            val hunterRuling = response.hunter.ruling
            val hunterResultResId =
                    if (hunterRuling == Ruling.POSITIVE)
                        R.string.snackbar_hunter_action_result_positive
                    else R.string.snackbar_hunter_action_result_negative
            Snackbar.make(view!!, hunterResultResId, LENGTH_LONG).show()
        }
    }

    private fun createTakeActionRequestBuilder(): TakeActionRequest.Builder {
        val gameId = roomService!!.room.game.id
        return TakeActionRequest.newBuilder().setGameId(gameId)
    }
}
