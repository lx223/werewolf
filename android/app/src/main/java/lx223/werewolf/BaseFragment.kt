package lx223.werewolf

import android.content.Context
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import lx223.werewolf.proto.GameServiceGrpc
import java.util.function.Consumer

abstract class BaseFragment : Fragment() {

    private var _eventListener: GameEventListener? = null
    val eventListener get() = _eventListener

    // TODO: change following variables to getter pattern.
    var activity: GameActivity? = null
    var gameService: GameServiceGrpc.GameServiceFutureStub? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        _eventListener = context as GameEventListener
        activity = context as GameActivity
        gameService = activity?.gameService
    }

    override fun onDetach() {
        super.onDetach()
        _eventListener = null
        activity = null
        gameService = null
    }

    fun runOnUiThread(action: () -> Unit) {
        activity?.runOnUiThread(action)
    }

    fun <V> addUiThreadCallback(future: ListenableFuture<V>?, callback: Consumer<V>) {
        Futures.transform(
                future,
                { result -> callback.accept(result!!) },
                ContextCompat.getMainExecutor(activity)
        )
    }
}
