package jiang.sichu.werewolf

import android.app.Fragment
import android.content.Context
import jiang.sichu.werewolf.proto.GameServiceGrpc
import java.util.concurrent.ExecutorService

abstract class BaseFragment : Fragment() {

    var activity: GameActivity? = null
    var executor: ExecutorService? = null
    var gameService: GameServiceGrpc.GameServiceBlockingStub? = null

    override fun onAttach(context: Context?) {
        super.onAttach(context)
        activity = context as GameActivity
        executor = activity?.executor
        gameService = activity?.gameService
    }

    override fun onDetach() {
        super.onDetach()
        activity = null
        executor = null
        gameService = null
    }

    fun runOnUiThread(action: () -> Unit) {
        activity?.runOnUiThread(action)
    }
}
