import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<bool> requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    return micStatus.isGranted && storageStatus.isGranted;
  }

  Future<String?> startRecording() async {
    try {
      if (!await requestPermissions()) {
        throw Exception('Microphone permission not granted');
      }

      if (await _recorder.hasPermission()) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final filePath = '${directory.path}/$fileName';
        
        // Start recording
        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        
        _currentRecordingPath = filePath;
        _isRecording = true;
        
        return filePath;
      }
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
    return null;
  }

  Future<String?> stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _isRecording = false;
        _currentRecordingPath = path;
        return path;
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
    return null;
  }

  Future<File?> getRecordingFile() async {
    if (_currentRecordingPath != null) {
      return File(_currentRecordingPath!);
    }
    return null;
  }

  Future<void> deleteRecording() async {
    try {
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _currentRecordingPath = null;
      }
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }

  Future<int> getAmplitude() async {
    try {
      if (_isRecording) {
        return await _recorder.getAmplitude();
      }
    } catch (e) {
      print('Error getting amplitude: $e');
    }
    return 0;
  }

  void dispose() {
    _recorder.dispose();
  }
}

// Audio Recorder Widget Example
class AudioRecorderWidget extends StatefulWidget {
  final Function(File?) onRecordingComplete;
  final Function(bool) onRecordingStateChanged;

  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    required this.onRecordingStateChanged,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioService.requestPermissions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      widget.onRecordingStateChanged(true);
      
      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioService.stopRecording();
    setState(() {
      _isRecording = false;
    });
    widget.onRecordingStateChanged(false);
    
    if (path != null) {
      final file = File(path);
      widget.onRecordingComplete(file);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isRecording) ...[
          const Icon(
            Icons.fiber_manual_record,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_recordingDuration),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
        ],
        ElevatedButton.icon(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          icon: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
          ),
          label: Text(
            _isRecording ? 'Stop' : 'Record',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRecording ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }
}