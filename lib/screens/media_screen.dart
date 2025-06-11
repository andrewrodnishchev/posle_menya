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

  Widget _buildMediaSourceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Добавить медиа',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          _buildDialogOption(
            icon: Icons.photo_library,
            title: 'Из галереи',
            onTap: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
          ),
          _buildDialogOption(
            icon: Icons.camera_alt,
            title: 'Камера',
            onTap: () {
              Navigator.pop(context);
              _showCameraOptions();
            },
          ),
          _buildDialogOption(
            icon: Icons.mic,
            title: 'Запись аудио',
            onTap: () {
              Navigator.pop(context);
              _handleAudioRecording();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDialogOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
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

  Widget _buildCameraOptionsDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Режим камеры',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          _buildDialogOption(
            icon: Icons.camera,
            title: 'Фото',
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
          _buildDialogOption(
            icon: Icons.videocam,
            title: 'Видео',
            onTap: () {
              Navigator.pop(context);
              _recordVideo();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _showCameraOptions() async {
    if (!_isCameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Камера не инициализирована'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _buildCameraOptionsDialog(),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isSelectionMode
              ? 'Выбрано: ${_selectedFiles.where((element) => element).length}'
              : 'Видео и аудио',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_mediaFiles.isNotEmpty && !_isSelectionMode)
            IconButton(
              icon: Icon(
                Icons.check_box_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: _deleteSelectedFiles,
            ),
          if (_isSelectionMode)
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
        onPressed: () => showDialog(
          context: context,
          builder: (context) => _buildMediaSourceDialog(),
        ),
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

        return Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _playVideo(file, index),
            onLongPress: () {
              setState(() {
                _isSelectionMode = true;
                _selectedFiles[index] = true;
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
                            child: Center(
                              child: Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }
                        return child;
                      },
                    )
                  else if (isAudio)
                    Container(
                      color: Theme.of(context).cardTheme.color,
                      child: Center(
                        child: Icon(
                          Icons.audiotrack,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Checkbox(
                          value: _selectedFiles[index],
                          onChanged: (value) => _toggleFileSelection(index),
                          fillColor: WidgetStateProperty.resolveWith<Color>((
                            Set<WidgetState> states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return Theme.of(context).colorScheme.primary;
                            }
                            return Theme.of(context).colorScheme.surface;
                          }),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),

                  if (isPlaying && !_isSelectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          Icons.stop,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () => _playVideo(file, index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
