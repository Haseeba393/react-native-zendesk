package com.rnzendesk

import android.content.Intent
import android.net.Uri
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.util.Base64
import java.util.concurrent.Executors
import zendesk.core.AnonymousIdentity
import zendesk.core.Zendesk
import zendesk.support.CustomField
import zendesk.support.Support
import zendesk.support.guide.HelpCenterActivity
import zendesk.support.guide.ViewArticleActivity
import zendesk.support.request.RequestActivity
import zendesk.support.requestlist.RequestListActivity

@ReactModule(name = ZendeskModule.NAME)
class ZendeskModule(reactContext: ReactApplicationContext) :
  NativeZendeskSpec(reactContext) {

  companion object {
    const val NAME = "RNZendesk"
  }

  private val httpClient = OkHttpClient()
  private val executor = Executors.newSingleThreadExecutor()

  private var subdomain: String? = null
  private var email: String? = null
  private var apiToken: String? = null
  private var locale: String = ""
  private var sdkInitialized: Boolean = false

  override fun getName(): String = NAME

  override fun initialize(config: ReadableMap, promise: Promise) {
    val providedSubdomain = config.getString("subdomain")
    email = config.getString("email")
    apiToken = config.getString("apiToken")
    locale = config.getString("locale") ?: ""

    val zendeskUrl = config.getString("zendeskUrl")
    val appId = config.getString("appId")
    val clientId = config.getString("clientId")
    val name = config.getString("name")

    val derivedSubdomain = extractSubdomainFromZendeskUrl(zendeskUrl)
    subdomain = if (!providedSubdomain.isNullOrBlank()) {
      providedSubdomain
    } else {
      derivedSubdomain
    }

    if (subdomain.isNullOrBlank()) {
      promise.reject(
        "E_ZENDESK_CONFIG",
        "Provide subdomain or a valid zendeskUrl (https://<subdomain>.zendesk.com)"
      )
      return
    }

    sdkInitialized = false
    if (!zendeskUrl.isNullOrBlank() && !appId.isNullOrBlank() && !clientId.isNullOrBlank()) {
      try {
        Zendesk.INSTANCE.init(reactApplicationContext, zendeskUrl, appId, clientId)
        Support.INSTANCE.init(Zendesk.INSTANCE)

        val identityBuilder = AnonymousIdentity.Builder()
        if (!name.isNullOrBlank()) {
          identityBuilder.withNameIdentifier(name)
        }
        if (!email.isNullOrBlank()) {
          identityBuilder.withEmailIdentifier(email)
        }
        Zendesk.INSTANCE.setIdentity(identityBuilder.build())

        if (locale.isNotBlank()) {
          Support.INSTANCE.setHelpCenterLocaleOverride(java.util.Locale.forLanguageTag(locale))
        }
        sdkInitialized = true
      } catch (error: Exception) {
        promise.reject("E_ZENDESK_SDK_INIT", error.message, error)
        return
      }
    }
    promise.resolve(true)
  }

  override fun getArticles(
    locale: String?,
    labels: ReadableArray?,
    page: Double?,
    perPage: Double?,
    promise: Promise
  ) {
    // Use native Help Center UI instead of REST APIs.
    openHelpCenter(promise)
  }

  override fun getArticle(articleId: Double, locale: String?, promise: Promise) {
    // Use native article UI instead of REST APIs.
    openArticle(articleId, promise)
  }

  override fun searchArticles(
    query: String,
    locale: String?,
    page: Double?,
    perPage: Double?,
    promise: Promise
  ) {
    // Search is handled by native Help Center UI.
    openHelpCenter(promise)
  }

  override fun createTicket(request: ReadableMap, promise: Promise) {
    // Use native contact support UI instead of REST ticket APIs.
    openContactSupport(promise)
  }

  override fun openHelpCenter(promise: Promise) {
    val domain = requireSubdomain(promise) ?: return
    val activity = currentActivity
    if (sdkInitialized && activity != null) {
      try {
        HelpCenterActivity.builder().show(activity)
        promise.resolve(true)
      } catch (error: Exception) {
        promise.reject("E_ZENDESK_OPEN_HELP_CENTER", error.message, error)
      }
      return
    }
    val localeSegment = if (locale.isNotBlank()) "/$locale" else ""
    openUrl("https://$domain.zendesk.com/hc$localeSegment", promise)
  }

  override fun openArticle(articleId: Double, promise: Promise) {
    val domain = requireSubdomain(promise) ?: return
    val id = articleId.toLong()
    val activity = currentActivity
    if (sdkInitialized && activity != null) {
      try {
        ViewArticleActivity.builder(id).show(activity)
        promise.resolve(true)
      } catch (error: Exception) {
        promise.reject("E_ZENDESK_OPEN_ARTICLE", error.message, error)
      }
      return
    }
    openUrl("https://$domain.zendesk.com/hc/articles/$id", promise)
  }

  override fun openContactSupport(promise: Promise) {
    val domain = requireSubdomain(promise) ?: return
    val activity = currentActivity
    if (sdkInitialized && activity != null) {
      try {
        RequestListActivity.builder().show(activity)
        promise.resolve(true)
      } catch (error: Exception) {
        promise.reject("E_ZENDESK_OPEN_CONTACT_SUPPORT", error.message, error)
      }
      return
    }
    val localeSegment = if (locale.isNotBlank()) "/$locale" else ""
    openUrl("https://$domain.zendesk.com/hc$localeSegment/requests/new", promise)
  }

  override fun openContactSupportWithDetails(
    email: String,
    customFields: ReadableArray,
    promise: Promise
  ) {
    val domain = requireSubdomain(promise) ?: return
    val activity = currentActivity

    if (sdkInitialized && activity != null) {
      try {
        if (email.isNotBlank()) {
          val identity = AnonymousIdentity.Builder()
            .withEmailIdentifier(email)
            .build()
          Zendesk.INSTANCE.setIdentity(identity)
        }

        val fields = arrayListOf<CustomField>()
        for (i in 0 until customFields.size()) {
          val item = customFields.getMap(i)
          val key = item.getString("key") ?: continue
          val value = item.getString("value") ?: continue
          val fieldId = key.trim().removeSuffix("L").toLongOrNull() ?: continue
          fields.add(CustomField(fieldId, value))
        }

        RequestActivity.builder()
          .withCustomFields(fields)
          .show(activity)
        promise.resolve(true)
      } catch (error: Exception) {
        promise.reject("E_ZENDESK_OPEN_CONTACT_SUPPORT", error.message, error)
      }
      return
    }

    val localeSegment = if (locale.isNotBlank()) "/$locale" else ""
    openUrl("https://$domain.zendesk.com/hc$localeSegment/requests/new", promise)
  }

  private fun openUrl(url: String, promise: Promise) {
    try {
      val activity = currentActivity
      if (activity == null) {
        promise.reject("E_ZENDESK_ACTIVITY", "No active activity available")
        return
      }

      val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
      activity.startActivity(intent)
      promise.resolve(true)
    } catch (error: Exception) {
      promise.reject("E_ZENDESK_OPEN_URL", error.message, error)
    }
  }

  private fun request(method: String, url: String, payload: String?, promise: Promise) {
    executor.execute {
      try {
        val requestBuilder = Request.Builder().url(url)
        authHeader()?.let { requestBuilder.addHeader("Authorization", it) }
        requestBuilder.addHeader("Accept", "application/json")

        if (method == "POST") {
          val body = (payload ?: "{}").toRequestBody("application/json".toMediaType())
          requestBuilder.post(body)
        } else {
          requestBuilder.get()
        }

        httpClient.newCall(requestBuilder.build()).execute().use { response ->
          val body = response.body?.string() ?: "{}"
          if (!response.isSuccessful) {
            promise.reject(
              "E_ZENDESK_HTTP",
              "Zendesk request failed (${response.code}): $body"
            )
            return@use
          }

          val json = JSONObject(body)
          val map = Arguments.makeNativeMap(json.toMap())
          promise.resolve(map)
        }
      } catch (error: IOException) {
        promise.reject("E_ZENDESK_NETWORK", error.message, error)
      } catch (error: Exception) {
        promise.reject("E_ZENDESK_UNKNOWN", error.message, error)
      }
    }
  }

  private fun JSONObject.toMap(): MutableMap<String, Any?> {
    val map = mutableMapOf<String, Any?>()
    keys().forEach { key ->
      map[key] = when (val value = get(key)) {
        is JSONArray -> value.toList()
        is JSONObject -> value.toMap()
        JSONObject.NULL -> null
        else -> value
      }
    }
    return map
  }

  private fun JSONArray.toList(): List<Any?> {
    val list = mutableListOf<Any?>()
    for (index in 0 until length()) {
      val value = get(index)
      list.add(
        when (value) {
          is JSONArray -> value.toList()
          is JSONObject -> value.toMap()
          JSONObject.NULL -> null
          else -> value
        }
      )
    }
    return list
  }

  private fun configuredApiBaseUrl(promise: Promise): String? {
    val domain = requireSubdomain(promise) ?: return null
    return "https://$domain.zendesk.com/api/v2"
  }

  private fun effectiveLocale(requestedLocale: String?): String = requestedLocale ?: locale

  private fun authHeader(): String? {
    if (email.isNullOrBlank() || apiToken.isNullOrBlank()) {
      return null
    }
    val token = "${email}/token:$apiToken"
    val encoded = Base64.getEncoder().encodeToString(token.toByteArray(Charsets.UTF_8))
    return "Basic $encoded"
  }

  private fun requireSubdomain(promise: Promise): String? {
    val domain = subdomain
    if (domain.isNullOrBlank()) {
      promise.reject("E_ZENDESK_CONFIG", "Zendesk is not initialized. Call initialize() first.")
      return null
    }
    return domain
  }

  private fun extractSubdomainFromZendeskUrl(zendeskUrl: String?): String? {
    if (zendeskUrl.isNullOrBlank()) {
      return null
    }
    return try {
      val host = Uri.parse(zendeskUrl).host ?: return null
      if (!host.endsWith(".zendesk.com")) {
        return null
      }
      host.substringBefore(".zendesk.com").takeIf { it.isNotBlank() }
    } catch (_: Exception) {
      null
    }
  }
}
