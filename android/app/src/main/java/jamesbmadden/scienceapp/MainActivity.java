package jamesbmadden.scienceapp;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.media.MediaRecorder;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.content.pm.PackageManager;

import java.io.IOException;

import android.Manifest;

import android.util.Log;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "jamesbmadden.scienceapp/noise";

  private static final String TAG = "MainActivity";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
          if (call.method.equals("micOn")) {
            micOn();
            result.success(true);
          } else if (call.method.equals("getMaxAmp")) {
            int amp = getMaxAmp();
            result.success(amp);
          } else if (call.method.equals("micOff")) {
            micOff();
            result.success(true);
          }
        }
      });
  }

  private MediaRecorder rec = null;
  private boolean permitted = false;
  private final int RECORD_AUDIO_PERMISSION = 1;

  private void micOn() {
    if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
      permitted = true;
      rec = new MediaRecorder();
      rec.setAudioSource(MediaRecorder.AudioSource.MIC);
      rec.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
      rec.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
      rec.setOutputFile("/dev/null"); 
      try {
        rec.prepare();
        rec.start();
      } catch (IOException e) {
      }
    } else {
      ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.RECORD_AUDIO}, RECORD_AUDIO_PERMISSION);
    }
  }

  private void micOff() {
    if (rec != null) {
      rec.stop();       
      rec.release();
      rec = null;
    }
  }

  private int getMaxAmp() {
    if (rec != null) {
      return rec.getMaxAmplitude();
    } else {
      return -1;
    }
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
    switch (requestCode) {
      case RECORD_AUDIO_PERMISSION: {
        if (grantResults.length > 0
          && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
          permitted = true;
          micOn();
        } else {
          permitted = false;
        }
        return;
      }
    }
  }

}
