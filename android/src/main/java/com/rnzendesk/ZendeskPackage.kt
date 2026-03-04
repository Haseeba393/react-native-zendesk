package com.rnzendesk

import com.facebook.react.TurboReactPackage
import com.facebook.react.ViewManagerOnDemandReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.uimanager.ViewManager

class ZendeskPackage :
  TurboReactPackage(),
  ViewManagerOnDemandReactPackage {

  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return if (name == ZendeskModule.NAME) {
      ZendeskModule(reactContext)
    } else {
      null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      mapOf(
        ZendeskModule.NAME to ReactModuleInfo(
          ZendeskModule.NAME,
          ZendeskModule::class.java.name,
          false,
          false,
          true,
          false,
          true
        )
      )
    }
  }

  override fun createViewManagers(
    reactContext: ReactApplicationContext
  ): List<ViewManager<*, *>> {
    return listOf(ZendeskHelpCenterViewManager())
  }

  override fun getViewManagerNames(reactContext: ReactApplicationContext): MutableList<String> {
    return mutableListOf(ZendeskHelpCenterViewManager.REACT_CLASS)
  }

  override fun createViewManager(
    reactContext: ReactApplicationContext,
    viewManagerName: String
  ): ViewManager<*, *>? {
    return if (viewManagerName == ZendeskHelpCenterViewManager.REACT_CLASS) {
      ZendeskHelpCenterViewManager()
    } else {
      null
    }
  }
}
