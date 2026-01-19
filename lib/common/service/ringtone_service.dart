import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

class RingtoneService {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Logger _logger = Logger();

  Future<void> playIncomingCall() async {
    try {
      _logger.d('Playing incoming call ringtone');
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/call.mp3'));
    } catch (e) {
      _logger.e('Failed to play ringtone: $e');
    }
  }

  Future<void> stop() async {
    try {
      _logger.d('Stopping ringtone');
      await _audioPlayer.stop();
    } catch (e) {
      _logger.e('Failed to stop ringtone: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
