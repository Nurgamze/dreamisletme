package sds.dream

import android.bluetooth.BluetoothAdapter
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel



class MainActivity: FlutterActivity() {


    private val CHANNEL = "bluetooth.channel"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            when (call.method) {
                "deviceName" -> getDeviceName(result)
            }
        }
    }



    private fun getDeviceName(result: MethodChannel.Result) {
        val mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        result.success(mBluetoothAdapter.name);
    }





}
