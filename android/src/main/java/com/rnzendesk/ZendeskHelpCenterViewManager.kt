package com.rnzendesk

import android.annotation.SuppressLint
import android.webkit.WebSettings
import android.webkit.WebView
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class ZendeskHelpCenterViewManager : SimpleViewManager<WebView>() {
  companion object {
    const val REACT_CLASS = "RNZendeskHelpCenterView"
  }

  override fun getName(): String = REACT_CLASS

  @SuppressLint("SetJavaScriptEnabled")
  override fun createViewInstance(reactContext: ThemedReactContext): WebView {
    return WebView(reactContext).apply {
      settings.javaScriptEnabled = true
      settings.domStorageEnabled = true
      settings.cacheMode = WebSettings.LOAD_DEFAULT
    }
  }

  @ReactProp(name = "url")
  fun setUrl(view: WebView, url: String?) {
    if (url.isNullOrBlank()) {
      return
    }
    view.loadUrl(url)
  }

  @ReactProp(name = "javaScriptEnabled", defaultBoolean = true)
  fun setJavaScriptEnabled(view: WebView, enabled: Boolean) {
    view.settings.javaScriptEnabled = enabled
  }
}
