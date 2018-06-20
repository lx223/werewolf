package jiang.sichu.werewolf

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import jiang.sichu.werewolf.proto.Werewolf.Role
import jiang.sichu.werewolf.proto.Werewolf.Role.*
import jiang.sichu.werewolf.proto.Werewolf.UpdateGameConfigRequest
import jiang.sichu.werewolf.proto.Werewolf.UpdateGameConfigRequest.RoleCount
import kotlinx.android.synthetic.main.fragment_game_config.view.*
import kotlinx.android.synthetic.main.item_game_config.view.*

private val ROLES = arrayOf(
        VILLAGER, WEREWOLF, SEER, WITCH, HUNTER, IDIOT, WHITE_WEREWOLF, GUARDIAN, HALF_BLOOD
        // Role.ORPHAN is not implemented yet.
)

class GameConfigFragment : GameFragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_game_config, container, false)
        val adapter = RoleAdapter(context)
        view.grid_roles.adapter = adapter
        view.btn_submit_config.setOnClickListener {
            updateGameConfig(adapter.counts)
        }
        return view
    }

    private fun updateGameConfig(roleCounts: HashMap<Role, Int>) {
        executor?.execute {
            gameService?.updateGameConfig(buildUpdateGameConfigRequest(roleCounts))
            activity?.onUpdateGameConfigSuccess()
        }
    }

    private fun buildUpdateGameConfigRequest(counts: Map<Role, Int>): UpdateGameConfigRequest {
        val builder = UpdateGameConfigRequest.newBuilder().setRoomId(activity?.roomId)
        counts.filter { entry -> entry.value > 0 }.forEach { role, count ->
            builder.addRoleCounts(RoleCount.newBuilder().setRole(role).setCount(count).build())
        }
        return builder.build()
    }

    class RoleAdapter(private val context: Context?) : BaseAdapter() {

        val counts = HashMap<Role, Int>().apply { ROLES.forEach { role -> put(role, 0) } }

        override fun getCount(): Int = ROLES.size

        override fun getItem(position: Int): Any? = Pair(ROLES[position], counts[ROLES[position]])

        override fun getItemId(position: Int): Long = ROLES[position].number.toLong()

        @SuppressLint("ViewHolder")
        override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
            val role = ROLES[position]
            val view = View.inflate(context, R.layout.item_game_config, null)
            view.image_role.setImageResource(getImageResIdForRole(role))
            if (role == Role.VILLAGER || role == Role.WEREWOLF) {
                view.switch_add_role.visibility = View.GONE
                view.edittext_role_count.visibility = View.VISIBLE
                view.edittext_role_count.addTextChangedListener(object : TextWatcher {
                    override fun afterTextChanged(s: Editable?) {}
                    override fun beforeTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                        counts[role] = s.toString().toInt()
                    }
                })
            } else {
                view.switch_add_role.visibility = View.VISIBLE
                view.edittext_role_count.visibility = View.GONE
                view.switch_add_role.setOnCheckedChangeListener { _, isChecked ->
                    counts[role] = if (isChecked) 1 else 0
                }
            }
            return view
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
            else -> throw RuntimeException("Unsupported role: $role")
        }
    }
}
