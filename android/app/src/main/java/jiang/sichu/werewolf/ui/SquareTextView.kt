package jiang.sichu.werewolf.ui

import android.content.Context
import android.util.AttributeSet
import android.widget.TextView

class SquareTextView(context: Context?, attrs: AttributeSet?) : TextView(context, attrs) {
    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) =
            super.onMeasure(widthMeasureSpec, widthMeasureSpec)
}
