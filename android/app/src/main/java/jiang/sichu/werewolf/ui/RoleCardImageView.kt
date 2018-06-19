package jiang.sichu.werewolf.ui

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.ImageView
import jiang.sichu.werewolf.R
import jiang.sichu.werewolf.proto.Werewolf
import jiang.sichu.werewolf.proto.Werewolf.Role.*

@SuppressLint("ResourceType")
class RoleCardImageView(context: Context, attrs: AttributeSet?) : ImageView(context, attrs) {

    private val backImageRes = R.raw.back
    private var role: Werewolf.Role? = null
    private var isShowing = false

    fun setRole(role: Werewolf.Role?) {
        this.role = role
        if (role == null) {
            visibility = View.INVISIBLE
        } else {
            visibility = View.VISIBLE
            setImageResource(backImageRes)
            isShowing = false
            setOnClickListener {
                setImageResource(if (isShowing) backImageRes else getFrontImageRes(role))
                isShowing = !isShowing
            }
        }
    }

    private fun getFrontImageRes(role: Werewolf.Role): Int {
        return when (role) {
            VILLAGER -> R.raw.villager
            SEER -> R.raw.seer
            WITCH -> R.raw.witch
            HUNTER -> R.raw.hunter
            IDIOT -> R.raw.idiot
            GUARDIAN -> R.raw.guardian
            WEREWOLF -> R.raw.werewolf
            WHITE_WEREWOLF -> R.raw.white_wolf
            HALF_BLOOD -> R.raw.half_blood
            ORPHAN -> R.raw.back // not implemented yet
            else -> R.raw.back // unexpected
        }
    }
}
