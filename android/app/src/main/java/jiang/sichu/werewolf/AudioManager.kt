package jiang.sichu.werewolf

import android.content.Context
import android.media.MediaPlayer
import android.support.annotation.RawRes
import jiang.sichu.werewolf.proto.Werewolf
import jiang.sichu.werewolf.proto.Werewolf.Game.State.*
import java.util.*

class AudioManager(private val context: Context) {

    enum class Type { START, END }

    private var queue: Queue<Int> = LinkedList()
    private var currentMediaPlayer: MediaPlayer? = null

    fun shutdown() {
        queue.clear()
        currentMediaPlayer?.stop()
        currentMediaPlayer?.release()
    }

    fun enqueue(gameState: Werewolf.Game.State, type: Type) {
        val wasEmpty = queue.isEmpty()
        queue.offer(getAudioResId(gameState, type))
        if (wasEmpty) {
            playNext()
        }
    }

    private fun playNext() {
        currentMediaPlayer?.release()
        currentMediaPlayer =
                MediaPlayer.create(context, queue.peek()).apply {
                    setOnCompletionListener {
                        queue.poll()
                        if (!queue.isEmpty()) {
                            playNext()
                        }
                    }
                    start()
                }
    }

    @RawRes
    private fun getAudioResId(gameState: Werewolf.Game.State, type: Type): Int {
        val isStart = type == Type.START
        return when (gameState) {
            UNKNOWN -> if (isStart) throw IllegalArgumentException() else R.raw.game_starts
            ORPHAN_AWAKE -> if (isStart) R.raw.orphan_start else R.raw.orphan_end
            HALF_BLOOD_AWAKE -> if (isStart) R.raw.half_blood_start else R.raw.half_blood_end
            GUARDIAN_AWAKE -> if (isStart) R.raw.guardian_start else R.raw.guardian_end
            WEREWOLF_AWAKE -> if (isStart) R.raw.werewolf_start else R.raw.werewolf_end
            WITCH_AWAKE -> if (isStart) R.raw.witch_start else R.raw.witch_end
            SEER_AWAKE -> if (isStart) R.raw.seer_start else R.raw.seer_end
            HUNTER_AWAKE -> if (isStart) R.raw.hunter_start else R.raw.hunter_end
            SHERIFF_ELECTION -> if (isStart) R.raw.sheriff else throw IllegalArgumentException()
            UNRECOGNIZED -> throw IllegalArgumentException()
        }
    }
}