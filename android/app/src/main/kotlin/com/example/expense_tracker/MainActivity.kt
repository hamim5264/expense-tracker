package com.example.expense_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.telephony.SmsMessage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "com.example.expense_tracker/sms"
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    smsReceiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context?, intent: Intent?) {
                            if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
                                val bundle = intent.extras
                                if (bundle != null) {
                                    val pdus = bundle.get("pdus") as Array<*>?
                                    if (pdus != null) {
                                        for (pdu in pdus) {
                                            val format = bundle.getString("format")
                                            val message = SmsMessage.createFromPdu(pdu as ByteArray, format)
                                            val sender = message.originatingAddress
                                            val body = message.messageBody
                                            val time = message.timestampMillis
                                            val data = mapOf(
                                                "sender" to sender,
                                                "body" to body,
                                                "timestamp" to time
                                            )
                                            events?.success(data)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED")
                    registerReceiver(smsReceiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    if (smsReceiver != null) {
                        try {
                            unregisterReceiver(smsReceiver)
                        } catch (e: Exception) {
                            // Ignored
                        }
                        smsReceiver = null
                    }
                }
            }
        )
    }
}
