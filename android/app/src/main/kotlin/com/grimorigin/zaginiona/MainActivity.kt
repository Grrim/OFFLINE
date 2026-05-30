package com.grimorigin.zaginiona

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // No heavy tasks here to ensure fast boot and prevent ANR.
    }
}
