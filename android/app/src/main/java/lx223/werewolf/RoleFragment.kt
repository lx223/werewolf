package lx223.werewolf


import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.annotation.RawRes
import androidx.annotation.StringRes
import lx223.werewolf.proto.Werewolf
import lx223.werewolf.proto.Werewolf.GetRoomRequest
import lx223.werewolf.databinding.FragmentRoleBinding

private const val BACK_IMAGE_RES = R.raw.back

@SuppressLint("ResourceType")
class RoleFragment : BaseFragment() {

    private var _binding: FragmentRoleBinding? = null
    private val binding get() = _binding!!

    private var isShowing = false

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        _binding = FragmentRoleBinding.inflate(inflater, container, false)
        binding.roleCard.setOnClickListener { onRoleCardClick() }
        return binding.root
    }

    override fun onResume() {
        super.onResume()
        showBackOfCard()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    private fun onRoleCardClick() {
        if (isShowing) {
            showBackOfCard()
        } else {
            showFrontOfCard()
        }
    }

    private fun showBackOfCard() {
        isShowing = false
        binding.roleCard.setImageResource(BACK_IMAGE_RES)
        binding.roleLabel.text = ""
    }

    private fun showFrontOfCard() {
        binding.roleCard.isClickable = false
        executor?.execute {
            val request = GetRoomRequest.newBuilder().setRoomId(activity?.roomId).build()
            val response = gameService?.getRoom(request)!!
            val myRole = response.room.seatsList.first { it.user.id == activity?.userId }.role
            runOnUiThread {
                isShowing = true
                binding.roleCard.isClickable = true
                binding.roleCard.setImageResource(getFrontImageRes(myRole))
                binding.roleLabel.text = getString(getRoleName(myRole))
            }
        }
    }

    @RawRes
    private fun getFrontImageRes(role: Werewolf.Role): Int {
        return when (role) {
            Werewolf.Role.VILLAGER -> R.raw.villager
            Werewolf.Role.SEER -> R.raw.seer
            Werewolf.Role.WITCH -> R.raw.witch
            Werewolf.Role.HUNTER -> R.raw.hunter
            Werewolf.Role.IDIOT -> R.raw.idiot
            Werewolf.Role.GUARDIAN -> R.raw.guardian
            Werewolf.Role.WEREWOLF -> R.raw.werewolf
            Werewolf.Role.WHITE_WEREWOLF -> R.raw.white_wolf
            Werewolf.Role.HALF_BLOOD -> R.raw.half_blood
            Werewolf.Role.ORPHAN -> BACK_IMAGE_RES // not implemented yet
            else -> throw IllegalArgumentException() // unexpected
        }
    }

    @StringRes
    private fun getRoleName(role: Werewolf.Role): Int {
        return when (role) {
            Werewolf.Role.VILLAGER -> R.string.role_villager
            Werewolf.Role.SEER -> R.string.role_seer
            Werewolf.Role.WITCH -> R.string.role_witch
            Werewolf.Role.HUNTER -> R.string.role_hunter
            Werewolf.Role.IDIOT -> R.string.role_idiot
            Werewolf.Role.GUARDIAN -> R.string.role_guardian
            Werewolf.Role.WEREWOLF -> R.string.role_werewolf
            Werewolf.Role.WHITE_WEREWOLF -> R.string.role_white_wolf
            Werewolf.Role.HALF_BLOOD -> R.string.role_half_blood
            Werewolf.Role.ORPHAN -> R.string.role_orphan
            else -> throw IllegalArgumentException() // unexpected
        }
    }
}
