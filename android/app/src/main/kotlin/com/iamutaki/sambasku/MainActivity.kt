@file:OptIn(UnstableApi::class)

package com.iamutaki.sambasku

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.BitmapOverlay
import androidx.media3.effect.OverlayEffect
import androidx.media3.effect.Presentation
import androidx.media3.effect.TextureOverlay
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.Transformer
import com.google.common.collect.ImmutableList
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "sambasku/share_video"
    private var transformer: Transformer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "compose") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val videoPath = call.argument<String>("videoPath")
                val overlayPath = call.argument<String>("overlayPngPath")
                val outputPath = call.argument<String>("outputPath")
                val maxSeconds = call.argument<Int>("maxSeconds") ?: 15
                if (videoPath == null || overlayPath == null || outputPath == null) {
                    result.error("bad_args", "argumen compose tidak lengkap", null)
                    return@setMethodCallHandler
                }
                compose(videoPath, overlayPath, outputPath, maxSeconds, result)
            }
    }

    private fun compose(
        videoPath: String,
        overlayPath: String,
        outputPath: String,
        maxSeconds: Int,
        result: MethodChannel.Result,
    ) {
        // Issue #165: decode bounds dulu, turunkan inSampleSize supaya
        // sisi panjang <= 1920 px (overlay dirender pixelRatio 2x di Dart,
        // full-res bisa 2160x2880 = ~25 MB bitmap).
        val bitmap = decodeOverlayScaled(overlayPath)
        if (bitmap == null) {
            result.error("no_overlay", "overlay PNG gagal dibaca", null)
            return
        }
        val overlay: TextureOverlay = BitmapOverlay.createStaticBitmapOverlay(bitmap)
        val overlayEffect = OverlayEffect(ImmutableList.of(overlay))
        val width = evenDimension(bitmap.width)
        val height = evenDimension(bitmap.height)
        val presentation =
            Presentation.createForWidthAndHeight(
                width,
                height,
                Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP,
            )
        val clipping =
            MediaItem.ClippingConfiguration.Builder()
                .setEndPositionMs(maxSeconds * 1000L)
                .build()
        val mediaItem =
            MediaItem.Builder()
                .setUri(Uri.fromFile(File(videoPath)))
                .setClippingConfiguration(clipping)
                .build()
        val edited =
            EditedMediaItem.Builder(mediaItem)
                .setRemoveAudio(true)
                .setEffects(Effects(listOf(), listOf(presentation, overlayEffect)))
                .build()

        val outFile = File(outputPath)
        if (outFile.exists()) outFile.delete()

        val main = Handler(Looper.getMainLooper())
        val active =
            Transformer.Builder(this)
                .setVideoMimeType(MimeTypes.VIDEO_H264)
                .addListener(
                    object : Transformer.Listener {
                        override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                            transformer = null
                            main.post { result.success(outputPath) }
                        }

                        override fun onError(
                            composition: Composition,
                            exportResult: ExportResult,
                            exportException: ExportException,
                        ) {
                            transformer = null
                            main.post {
                                result.error("export", exportException.message, null)
                            }
                        }
                    },
                )
                .build()
        transformer = active
        active.start(edited, outputPath)
    }

    private fun evenDimension(value: Int): Int = maxOf(2, value - (value % 2))

    private companion object {
        const val MAX_OVERLAY_DIM = 1920
    }

    // ponytail: granularity power-of-2 (2880 px turun ke 1440, bukan tepat
    // 1920) - cukup untuk overlay share; kalau butuh presisi, tambah
    // Bitmap.createScaledBitmap setelah decode.
    private fun decodeOverlayScaled(path: String): Bitmap? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null
        val longSide = maxOf(bounds.outWidth, bounds.outHeight)
        var sample = 1
        while (longSide / sample > MAX_OVERLAY_DIM) sample *= 2
        val options = BitmapFactory.Options().apply { inSampleSize = sample }
        return BitmapFactory.decodeFile(path, options)
    }
}
