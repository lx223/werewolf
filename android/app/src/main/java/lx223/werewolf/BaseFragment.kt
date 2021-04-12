package lx223.werewolf

import android.content.Context
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import lx223.werewolf.proto.GameServiceGrpc
import java.util.function.Consumer

abstract class BaseFragment : Fragment() {

    // TODO: refactor and remove _activity.
    private var _activity: GameActivity? = null
    private var _eventListener: GameEventListener? = null
    private var _gameService: GameServiceGrpc.GameServiceFutureStub? = null

    internal val activity get() = _activity!!
    internal val eventListener get() = _eventListener!!
    internal val gameService get() = _gameService!!

    override fun onAttach(context: Context) {
        super.onAttach(context)
        _activity = context as GameActivity
        _eventListener = context
        _gameService = _activity?.gameService
    }

    override fun onDetach() {
        super.onDetach()
        _activity = null
        _eventListener = null
        _gameService = null
    }

    fun runOnUiThread(action: () -> Unit) {
        activity.runOnUiThread(action)
    }

    fun <V> addUiThreadCallback(future: ListenableFuture<V>?, callback: Consumer<V>) {
        Futures.transform(
                future,
                { result -> callback.accept(result!!) },
                ContextCompat.getMainExecutor(activity)
        )
    }
}
