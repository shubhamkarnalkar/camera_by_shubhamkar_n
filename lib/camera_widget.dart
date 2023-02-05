// Automatic FlutterFlow imports
// import '../../backend/backend.dart';
// import '../../flutter_flow/flutter_flow_theme.dart';
// import '../../flutter_flow/flutter_flow_util.dart';
// import 'index.dart'; // Imports other custom widgets
// import '../../flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// // Begin custom widget code
// // DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import 'index.dart'; // Imports other custom widgets

// import 'index.dart'; // Imports other custom widgets

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';

// ///for blob
// import 'package:azblob/azblob.dart';
// import 'package:mime/mime.dart';

/// Camera example home widget.
class CameraExampleHome extends StatefulWidget {
  /// Default Constructor
  const CameraExampleHome({Key? key, this.width, this.height})
      : super(key: key);

  final double? width;
  final double? height;

  @override
  State<CameraExampleHome> createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      throw ArgumentError('Unknown lens direction');
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int direction = 0;
  List<CameraDescription> _cameras = <CameraDescription>[];
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  Future<void> initial() async {
    try {
      _cameras = await availableCameras();
      controller = CameraController(
        _cameras[direction],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      onNewCameraSelected(controller!.description);
    } on CameraException catch (e) {
      print(e.description);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initial();
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Camera example'),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: controller != null ? onFlashModeButtonPressed : null,
      //   child: const Icon(Icons.flash_on_rounded),
      //   backgroundColor: Colors.white.withOpacity(0.1),
      // ),
      // floatingActionButton:
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _cameraPreviewWidget(),
                  Positioned(
                      bottom: 0,
                      height: 100,
                      width: 370, //camera, flash, thumbnail image are here
                      child: _captureControlRowWidget()),
                  Positioned(top: 0, left: 0, child: _cameraTogglesRowWidget()),
                  // _thumbnailWidget(),
                  // Positioned(
                  //   top: 300,
                  //   right: 0,
                  //   child: SpeedDial(
                  //     // animatedIcon: AnimatedIcons.list_view,
                  //     icon: Icons.flash_on,
                  //     children: [
                  //       SpeedDialChild(
                  //         // ignore: prefer_const_constructors
                  //         // ignore: prefer_const_constructors
                  //         child: Icon(
                  //           Icons.flash_off,
                  //           color: Colors.amberAccent,
                  //         ),
                  //         label: 'Flash off',
                  //         backgroundColor:
                  //             controller?.value.flashMode == FlashMode.off
                  //                 ? Colors.orange
                  //                 : Colors.amberAccent,
                  //         onTap: controller != null
                  //             ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  //             : null,
                  //       ),
                  //       SpeedDialChild(
                  //         // ignore: prefer_const_constructors
                  //         child: Icon(
                  //           Icons.flash_auto_rounded,
                  //         ),
                  //         label: 'Flash Auto',
                  //         backgroundColor:
                  //             controller?.value.flashMode == FlashMode.auto
                  //                 ? Colors.orange
                  //                 : Colors.amberAccent,
                  //         onTap: controller != null
                  //             ? () =>
                  //                 onSetFlashModeButtonPressed(FlashMode.auto)
                  //             : null,
                  //       ),
                  //       SpeedDialChild(
                  //         // ignore: prefer_const_constructors
                  //         child: Icon(
                  //           Icons.flash_on,
                  //         ),
                  //         label: 'Flash On',
                  //         backgroundColor:
                  //             controller?.value.flashMode == FlashMode.always
                  //                 ? Colors.orange
                  //                 : Colors.amberAccent,
                  //         onTap: controller != null
                  //             ? () =>
                  //                 onSetFlashModeButtonPressed(FlashMode.always)
                  //             : null,
                  //       ),
                  //       SpeedDialChild(
                  //         // ignore: prefer_const_constructors
                  //         child: Icon(
                  //           Icons.highlight,
                  //         ),
                  //         label: 'highlight',
                  //         backgroundColor:
                  //             controller?.value.flashMode == FlashMode.torch
                  //                 ? Colors.orange
                  //                 : Colors.amberAccent,
                  //         onTap: controller != null
                  //             ? () =>
                  //                 onSetFlashModeButtonPressed(FlashMode.torch)
                  //             : null,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
    } else {
      return CameraPreview(controller!);
      // Listener(
      //   onPointerDown: (_) => _pointers++,
      //   onPointerUp: (_) => _pointers--,
      //   child: CameraPreview(
      //     controller!,
      //     child: LayoutBuilder(
      //         builder: (BuildContext context, BoxConstraints constraints) {
      //       return GestureDetector(
      //         behavior: HitTestBehavior.opaque,
      //         onScaleStart: _handleScaleStart,
      //         onScaleUpdate: _handleScaleUpdate,
      //         onTapDown: (TapDownDetails details) =>
      //             onViewFinderTap(details, constraints),
      //       );
      //     }),
      //   ),
      // );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  // /// Display a bar with buttons to change the flash and exposure modes
  // Widget _modeControlRowWidget() {
  //   return Column(
  //     children: <Widget>[
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  // IconButton(
  //   icon: const Icon(Icons.flash_on),
  //   color: Colors.blue,
  //   onPressed: controller != null ? onFlashModeButtonPressed : null,
  // ),
  //   // The exposure and focus mode are currently not supported on the web.
  //   ...!kIsWeb
  //       ? <Widget>[
  //           IconButton(
  //             icon: const Icon(Icons.exposure),
  //             color: Colors.blue,
  //             onPressed: controller != null
  //                 ? onExposureModeButtonPressed
  //                 : null,
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.filter_center_focus),
  //             color: Colors.blue,
  //             onPressed:
  //                 controller != null ? onFocusModeButtonPressed : null,
  //           )
  //         ]
  //       : <Widget>[],
  //   IconButton(
  //     icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
  //     color: Colors.blue,
  //     onPressed: controller != null ? onAudioModeButtonPressed : null,
  //   ),
  //   IconButton(
  //     icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
  //         ? Icons.screen_lock_rotation
  //         : Icons.screen_rotation),
  //     color: Colors.blue,
  //     onPressed: controller != null
  //         ? onCaptureOrientationLockButtonPressed
  //         : null,
  //   ),
  //         ],
  //       ),
  //       // _flashModeControlRowWidget(),
  //       // _exposureModeControlRowWidget(),
  //       // _focusModeControlRowWidget(),
  //     ],
  //   );
  // }

  // Widget _flashModeControlRowWidget() {
  //   return SizeTransition(
  //     sizeFactor: _flashModeControlRowAnimation,
  //     child: ClipRect(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           IconButton(
  //             icon: const Icon(Icons.flash_off),
  //             color: controller?.value.flashMode == FlashMode.off
  //                 ? Colors.orange
  //                 : Colors.amberAccent,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.off)
  //                 : null,
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.flash_auto),
  //             color: controller?.value.flashMode == FlashMode.auto
  //                 ? Colors.orange
  //                 : Colors.amberAccent,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.auto)
  //                 : null,
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.flash_on),
  //             color: controller?.value.flashMode == FlashMode.always
  //                 ? Colors.orange
  //                 : Colors.amberAccent,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.always)
  //                 : null,
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.highlight),
  //             color: controller?.value.flashMode == FlashMode.torch
  //                 ? Colors.orange
  //                 : Colors.amberAccent,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.torch)
  //                 : null,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _exposureModeControlRowWidget() {
  //   final ButtonStyle styleAuto = TextButton.styleFrom(
  //     // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
  //     // ignore: deprecated_member_use
  //     primary: controller?.value.exposureMode == ExposureMode.auto
  //         ? Colors.orange
  //         : Colors.blue,
  //   );
  //   final ButtonStyle styleLocked = TextButton.styleFrom(
  //     // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
  //     // ignore: deprecated_member_use
  //     primary: controller?.value.exposureMode == ExposureMode.locked
  //         ? Colors.orange
  //         : Colors.blue,
  //   );

  //   return SizeTransition(
  //     sizeFactor: _exposureModeControlRowAnimation,
  //     child: ClipRect(
  //       child: Container(
  //         color: Colors.amberAccent,
  //         child: Column(
  //           children: <Widget>[
  //             const Center(
  //               child: Text('Exposure Mode'),
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: <Widget>[
  //                 TextButton(
  //                   style: styleAuto,
  //                   onPressed: controller != null
  //                       ? () =>
  //                           onSetExposureModeButtonPressed(ExposureMode.auto)
  //                       : null,
  //                   onLongPress: () {
  //                     if (controller != null) {
  //                       controller!.setExposurePoint(null);
  //                       showInSnackBar('Resetting exposure point');
  //                     }
  //                   },
  //                   child: const Text('AUTO'),
  //                 ),
  //                 TextButton(
  //                   style: styleLocked,
  //                   onPressed: controller != null
  //                       ? () =>
  //                           onSetExposureModeButtonPressed(ExposureMode.locked)
  //                       : null,
  //                   child: const Text('LOCKED'),
  //                 ),
  //                 TextButton(
  //                   style: styleLocked,
  //                   onPressed: controller != null
  //                       ? () => controller!.setExposureOffset(0.0)
  //                       : null,
  //                   child: const Text('RESET OFFSET'),
  //                 ),
  //               ],
  //             ),
  //             const Center(
  //               child: Text('Exposure Offset'),
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: <Widget>[
  //                 Text(_minAvailableExposureOffset.toString()),
  //                 Slider(
  //                   value: _currentExposureOffset,
  //                   min: _minAvailableExposureOffset,
  //                   max: _maxAvailableExposureOffset,
  //                   label: _currentExposureOffset.toString(),
  //                   onChanged: _minAvailableExposureOffset ==
  //                           _maxAvailableExposureOffset
  //                       ? null
  //                       : setExposureOffset,
  //                 ),
  //                 Text(_maxAvailableExposureOffset.toString()),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _focusModeControlRowWidget() {
  //   final ButtonStyle styleAuto = TextButton.styleFrom(
  //     // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
  //     // ignore: deprecated_member_use
  //     primary: controller?.value.focusMode == FocusMode.auto
  //         ? Colors.orange
  //         : Colors.blue,
  //   );
  //   final ButtonStyle styleLocked = TextButton.styleFrom(
  //     // TODO(darrenaustin): Migrate to new API once it lands in stable: https://github.com/flutter/flutter/issues/105724
  //     // ignore: deprecated_member_use
  //     primary: controller?.value.focusMode == FocusMode.locked
  //         ? Colors.orange
  //         : Colors.blue,
  // );

  //   return SizeTransition(
  //     sizeFactor: _focusModeControlRowAnimation,
  //     child: ClipRect(
  //       child: Container(
  //         color: Colors.grey.shade50,
  //         child: Column(
  //           children: <Widget>[
  //             const Center(
  //               child: Text('Focus Mode'),
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: <Widget>[
  //                 TextButton(
  //                   style: styleAuto,
  //                   onPressed: controller != null
  //                       ? () => onSetFocusModeButtonPressed(FocusMode.auto)
  //                       : null,
  //                   onLongPress: () {
  //                     if (controller != null) {
  //                       controller!.setFocusPoint(null);
  //                     }
  //                     showInSnackBar('Resetting focus point');
  //                   },
  //                   child: const Text('AUTO'),
  //                 ),
  //                 TextButton(
  //                   style: styleLocked,
  //                   onPressed: controller != null
  //                       ? () => onSetFocusModeButtonPressed(FocusMode.locked)
  //                       : null,
  //                   child: const Text('LOCKED'),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;
    final VideoPlayerController? localVideoController = videoController;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          flex: 2,
          child: imageFile == null
              ? const SizedBox(
                  width: 100,
                  height: 100,
                )
              : Container(
                  height: 100,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Image.file(
                    File(imageFile!.path),
                  ),
                ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            icon: const Icon(Icons.radio_button_checked),
            iconSize: 80,
            color: Colors.white,
            onPressed: cameraController != null &&
                    cameraController.value.isInitialized &&
                    !cameraController.value.isRecordingVideo
                ? onTakePictureButtonPressed
                : null,
          ),
        ),
        SpeedDial(
          animatedIcon: AnimatedIcons.list_view,
          backgroundColor: Colors.white.withOpacity(0.3),
          //
          // child: const Icon(
          //   Icons.flash_on,
          //   color: Colors.amberAccent,
          // ),
          children: [
            SpeedDialChild(
              // ignore: prefer_const_constructors
              // ignore: prefer_const_constructors
              child: Icon(
                Icons.power_rounded,
                // color: Colors.amberAccent,
              ),
              label: 'Flash off',
              backgroundColor: controller?.value.flashMode == FlashMode.off
                  ? Colors.orange
                  : Colors.amberAccent,
              onTap: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
            ),
            SpeedDialChild(
              // ignore: prefer_const_constructors
              child: Icon(
                Icons.flash_auto_rounded,
              ),
              label: 'Flash Auto',
              backgroundColor: controller?.value.flashMode == FlashMode.auto
                  ? Colors.orange
                  : Colors.amberAccent,
              onTap: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
            ),
            SpeedDialChild(
              // ignore: prefer_const_constructors
              child: Icon(
                Icons.flash_on,
              ),
              label: 'Flash On',
              backgroundColor: controller?.value.flashMode == FlashMode.always
                  ? Colors.orange
                  : Colors.amberAccent,
              onTap: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
            ),
            SpeedDialChild(
              // ignore: prefer_const_constructors
              child: Icon(
                Icons.highlight,
              ),
              label: 'highlight',
              backgroundColor: controller?.value.flashMode == FlashMode.torch
                  ? Colors.orange
                  : Colors.amberAccent,
              onTap: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    }

    if (_cameras.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showInSnackBar('Initializing a camera');
      });
      return const Text('None');
    } else {
      for (final CameraDescription cameraDescription in _cameras) {
        toggles.add(
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 2,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            width: 100.0,
            height: 50,
            // color: Colors.white.withOpacity(0.3),
            child: RadioListTile<CameraDescription>(
              tileColor: Colors.white,
              activeColor: Colors.white,
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged:
                  controller != null && controller!.value.isRecordingVideo
                      ? null
                      : onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                    (double value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => _maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> uploadToBlob(XFile file) async {
    String? finalBlobUrl;
    // try {
    String fileName = file.path.split(Platform.pathSeparator).last;
    // read file as Uint8List
    // Uint8List content = await file.readAsBytes();
    // var storage = AzureStorage.parse(
    //     'DefaultEndpointsProtocol=https;AccountName=bokingcsvfiles;AccountKey=kJwQ/+FgJ+SUWtQHsTSl2Uxv9QqgagRytyBJkjB8Cc7XmAmv1rD46Ixs+rFfgajgDOaS8FN4pnt8+AStI0i92Q==;EndpointSuffix=core.windows.net');
    String container = "cardatacontainer";
    // get the mime type of the file
    // String? contentType = lookupMimeType(fileName);
    //Don't uncomment the following code
    // await storage.putBlob('/$container/$fileName',
    //     bodyBytes: content,
    //     contentType: contentType,
    //     type: BlobType.BlockBlob);
    finalBlobUrl =
        'https://bokingcsvfiles.blob.core.windows.net/$container/$fileName';
    print("done");
    // }
    // } on AzureStorageException catch (ex) {
    //   print(ex.message);
    // } catch (err) {
    //   print(err);
    // }
    return finalBlobUrl;
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) async {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) {
          // showInSnackBar('Picture saved to ${file.path}');
          // FFAppState().syncListForJsonImage.add(file.path);
          String? blobUrl = await uploadToBlob(file);
          // FFAppState().carImages.add(blobUrl!.toString());
          // print(FFAppState().carImages);
          await GallerySaver.saveImage(file.path, albumName: 'Airside')
              .then((value) => true);
          showInSnackBar('Picture saved to ${file.path}');
        }
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.network(videoFile!.path)
        : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null && videoController!.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();

      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
