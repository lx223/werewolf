package lx223.werewolf

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import lx223.werewolf.databinding.FragmentGameConfigBinding
import lx223.werewolf.databinding.ItemGameConfigBinding
import lx223.werewolf.proto.Werewolf.Role
import lx223.werewolf.proto.Werewolf.UpdateGameConfigRequest
import lx223.werewolf.proto.Werewolf.UpdateGameConfigRequest.RoleCount

private val ROLES = arrayOf(
        Role.VILLAGER,
        Role.WEREWOLF,
        Role.SEER,
        Role.WITCH,
        Role.HUNTER,
        Role.IDIOT,
        Role.WHITE_WEREWOLF,
        Role.GUARDIAN,
        Role.HALF_BLOOD,
        Role.ORPHAN,
)

class GameConfigFragment : BaseFragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        val binding = FragmentGameConfigBinding.inflate(inflater, container, false)
        val adapter = RoleAdapter(context)
        binding.gridRoles.adapter = adapter
        binding.btnSubmitConfig.setOnClickListener {
            updateGameConfig(adapter.counts)
        }
        return binding.root
    }

    private fun updateGameConfig(roleCounts: HashMap<Role, Int>) {
        val request = buildUpdateGameConfigRequest(roleCounts)
        addUiThreadCallback(gameService?.updateGameConfig(request)) {
            eventListener?.onUpdateGameConfigSuccess()
        }
    }

    private fun buildUpdateGameConfigRequest(counts: Map<Role, Int>): UpdateGameConfigRequest {
        val builder = UpdateGameConfigRequest.newBuilder().setRoomId(activity?.roomId)
        counts.filter { entry -> entry.value > 0 }.forEach { (role, count) ->
            builder.addRoleCounts(RoleCount.newBuilder().setRole(role).setCount(count).build())
        }
        return builder.build()
    }

    class RoleAdapter(private val context: Context?) : BaseAdapter() {

        val counts = HashMap<Role, Int>().apply { ROLES.forEach { role -> put(role, 0) } }

        override fun getCount(): Int = ROLES.size

        override fun getItem(position: Int): Any = Pair(ROLES[position], counts[ROLES[position]])

        override fun getItemId(position: Int): Long = ROLES[position].number.toLong()

        @SuppressLint("ViewHolder")
        override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
            val role = ROLES[position]
            val binding = ItemGameConfigBinding.inflate(LayoutInflater.from(context), parent, false)
            binding.imageRole.setImageResource(getImageResIdForRole(role))
            if (role == Role.VILLAGER || role == Role.WEREWOLF) {
                binding.switchAddRole.visibility = View.GONE
                binding.edittextRoleCount.visibility = View.VISIBLE
                binding.edittextRoleCount.addTextChangedListener(object : TextWatcher {
                    override fun afterTextChanged(s: Editable?) {}
                    override fun beforeTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                        counts[role] = s.toString().toInt()
                    }
                })
            } else {
                binding.switchAddRole.visibility = View.VISIBLE
                binding.edittextRoleCount.visibility = View.GONE
                binding.switchAddRole.setOnCheckedChangeListener { _, isChecked ->
                    counts[role] = if (isChecked) 1 else 0
                }
            }
            return binding.root
        }

        private fun getImageResIdForRole(role: Role) = when (role) {
            Role.VILLAGER -> R.raw.villager
            Role.WEREWOLF -> R.raw.werewolf
            Role.WHITE_WEREWOLF -> R.raw.white_wolf
            Role.SEER -> R.raw.seer
            Role.WITCH -> R.raw.witch
            Role.HUNTER -> R.raw.hunter
            Role.IDIOT -> R.raw.idiot
            Role.GUARDIAN -> R.raw.guardian
            Role.HALF_BLOOD -> R.raw.half_blood
            Role.ORPHAN -> R.raw.orphan
            else -> throw RuntimeException("Unsupported role: $role")
        }
    }
}
