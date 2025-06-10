import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:posle_menya/error_handler.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> with WidgetsBindingObserver {
  List<File> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;
  int? _playingIndex;
  late CameraController _cameraController;
  bool _isRecordingVideo = false;
  late RecorderController _audioRecorderController;
  bool _isRecordingAudio = false;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  List<bool> _selectedFiles = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioRecorderController = RecorderController();
    _initializeCamera();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = (await directory.list().toList())
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.png') ||
              file.path.endsWith('.mp4') ||
              file.path.endsWith('.mov') ||
              file.path.endsWith('.mp3') ||
              file.path.endsWith('.wav'),
        )
        .toList();

    setState(() {
      _mediaFiles = files;
      _selectedFiles = List<bool>.generate(files.length, (index) => false);
    });
  }

  Future<void> _saveFile(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(file.path);
    final savedFile = await file.copy('${directory.path}/$fileName');

    setState(() {
      _mediaFiles = [..._mediaFiles, savedFile];
      _selectedFiles = [..._selectedFiles, false];
    });
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
      );
      await _cameraController.initialize();
      setState(() => _isCameraInitialized = true);
    } catch (e, st) {
      if (mounted) AppErrorHandler.handleFileError(context, e, st);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isCameraInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    _cameraController.dispose();
    _audioRecorderController.dispose();
    super.dispose();
  }

  Future<void> _showMediaSourceDialog() async {
    final action = await showDialog<MediaAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить медиа'),
        backgroundColor: Theme.of(context).cardTheme.color,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Из галереи',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(context, MediaAction.gallery),
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Камера',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(context, MediaAction.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.mic,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Запись аудио',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(context, MediaAction.audio),
            ),
          ],
        ),
      ),
    );

    if (action == null) return;

    switch (action) {
      case MediaAction.gallery:
        await _pickFromGallery();
        break;
      case MediaAction.camera:
        await _showCameraOptions();
        break;
      case MediaAction.audio:
        await _handleAudioRecording();
        break;
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final files = await _picker.pickMedia(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (files != null && mounted) {
        await _saveFile(File(files.path));
      }
    } catch (e, st) {
      if (mounted) AppErrorHandler.handleFileError(context, e, st);
    }
  }

  Future<void> _showCameraOptions() async {
    if (!_isCameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Камера не инициализирована')),
      );
      return;
    }

    final option = await showDialog<CameraOption>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Режим камеры'),
        backgroundColor: Theme.of(context).cardTheme.color,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Фото',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(context, CameraOption.photo),
            ),
            ListTile(
              leading: Icon(
                Icons.videocam,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Видео',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(context, CameraOption.video),
            ),
          ],
        ),
      ),
    );

    if (option == null) return;

    if (option == CameraOption.photo) {
      await _takePhoto();
    } else {
      await _recordVideo();
    }
  }

  Future<void> _takePhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (file != null && mounted) {
        await _saveFile(File(file.path));
      }
    } catch (e, st) {
      if (mounted) AppErrorHandler.handleFileError(context, e, st);
    }
  }

  Future<void> _recordVideo() async {
    if (_isRecordingVideo) return;

    try {
      setState(() => _isRecordingVideo = true);
      final file = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (file != null && mounted) {
        await _saveFile(File(file.path));
      }
    } catch (e, st) {
      if (mounted) AppErrorHandler.handleFileError(context, e, st);
    } finally {
      setState(() => _isRecordingVideo = false);
    }
  }

  Future<void> _handleAudioRecording() async {
    if (_isRecordingAudio) {
      await _stopAudioRecording();
    } else {
      await _startAudioRecording();
    }
  }

  Future<void> _startAudioRecording() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      final filePath = path.join(dir.path, fileName);

      setState(() => _isRecordingAudio = true);
      await _audioRecorderController.record(path: filePath);
    } catch (e, st) {
      if (mounted) {
        AppErrorHandler.handleFileError(context, e, st);
        setState(() => _isRecordingAudio = false);
      }
    }
  }

  Future<void> _stopAudioRecording() async {
    final path = await _audioRecorderController.stop();
    if (path != null && mounted) {
      await _saveFile(File(path));
      setState(() => _isRecordingAudio = false);
    }
  }

  void _playVideo(File file, int index) async {
    if (_isSelectionMode) {
      _toggleFileSelection(index);
      return;
    }

    if (_playingIndex == index) {
      await _videoController?.pause();
      setState(() => _playingIndex = null);
      return;
    }

    _videoController?.dispose();
    _videoController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _playingIndex = index;
            _videoController!.play();
          });
        }
      })
      ..addListener(() {
        if (_videoController != null &&
            !_videoController!.value.isPlaying &&
            _videoController!.value.position ==
                _videoController!.value.duration) {
          if (mounted) {
            setState(() => _playingIndex = null);
          }
        }
      });
  }

  void _toggleFileSelection(int index) {
    setState(() {
      _selectedFiles[index] = !_selectedFiles[index];
      _isSelectionMode = _selectedFiles.contains(true);
    });
  }

  void _deleteSelectedFiles() {
    setState(() {
      final newMediaFiles = <File>[];
      final newSelectedFiles = <bool>[];

      for (int i = 0; i < _mediaFiles.length; i++) {
        if (!_selectedFiles[i]) {
          newMediaFiles.add(_mediaFiles[i]);
          newSelectedFiles.add(false);
        } else {
          if (_playingIndex == i) {
            _videoController?.dispose();
            _videoController = null;
            _playingIndex = null;
          }
          _mediaFiles[i].deleteSync();
        }
      }

      _mediaFiles = newMediaFiles;
      _selectedFiles = newSelectedFiles;
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text(
                'Выбрано: ${_selectedFiles.where((element) => element).length}',
              )
            : const Text('Медиафайлы'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          if (_mediaFiles.isNotEmpty && !_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.check_box_outlined),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                  _selectedFiles = List<bool>.generate(
                    _mediaFiles.length,
                    (index) => false,
                  );
                });
              },
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelectedFiles,
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedFiles = List<bool>.generate(
                    _mediaFiles.length,
                    (index) => false,
                  );
                });
              },
            ),
        ],
      ),
      body: _isRecordingAudio
          ? _buildAudioRecorder()
          : _mediaFiles.isEmpty
          ? _buildEmptyState()
          : _buildMediaGrid(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _showMediaSourceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAudioRecorder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Идет запись...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        AudioWaveforms(
          size: Size(MediaQuery.of(context).size.width * 0.8, 100),
          recorderController: _audioRecorderController,
          waveStyle: WaveStyle(
            waveColor: Theme.of(context).colorScheme.primary,
            showDurationLabel: true,
            spacing: 8,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _stopAudioRecording,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: const Icon(Icons.stop, size: 36),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
          ),
          const SizedBox(height: 20),
          Text(
            'Нет медиафайлов',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _mediaFiles.length,
      itemBuilder: (context, index) {
        final file = _mediaFiles[index];
        final isPlaying = _playingIndex == index;
        final isVideo =
            file.path.endsWith('.mp4') || file.path.endsWith('.mov');
        final isAudio =
            file.path.endsWith('.mp3') || file.path.endsWith('.wav');

        return GestureDetector(
          onTap: () => _playVideo(file, index),
          onLongPress: () {
            setState(() {
              _isSelectionMode = true;
              _selectedFiles[index] = true;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo && isPlaying && _videoController != null)
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                else if (isVideo)
                  Image.file(
                    file,
                    fit: BoxFit.cover,
                    frameBuilder: (_, child, frame, __) {
                      if (frame == null) {
                        return Container(
                          color: Theme.of(context).cardTheme.color,
                          child: const Center(
                            child: Icon(Icons.play_arrow, size: 40),
                          ),
                        );
                      }
                      return child;
                    },
                  )
                else if (isAudio)
                  Container(
                    color: Theme.of(context).cardTheme.color,
                    child: const Center(
                      child: Icon(Icons.audiotrack, size: 40),
                    ),
                  )
                else
                  Image.file(file, fit: BoxFit.cover),

                if (isVideo && !isPlaying && !_isSelectionMode)
                  Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(180),
                    ),
                  ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Text(
                      file.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Checkbox(
                      value: _selectedFiles[index],
                      onChanged: (value) => _toggleFileSelection(index),
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return Theme.of(context).colorScheme.primary;
                        }
                        return Colors.white;
                      }),
                    ),
                  ),

                if (isPlaying && !_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.stop, color: Colors.white),
                      onPressed: () => _playVideo(file, index),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum MediaAction { gallery, camera, audio }

enum CameraOption { photo, video }
