// Strealizer Music (https://github.com/strealizer/strealizer_music.git)

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:strealizer_music/common.dart';
import 'package:rxdart/rxdart.dart';

// App Config
const String appTitle = 'Strealizer Music';

// Stylesheets
const mainColor = Color.fromARGB(255, 29, 29, 29);

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(
    const MaterialApp(
      home: MyApp(title: appTitle),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required String title}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();

  // static MyAppState of(BuildContext context) =>
  //     context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  static int _nextMediaId = 0;
  late AudioPlayer _player;
  final _playlist = ConcatenatingAudioSource(children: [
    // ClippingAudioSource(
    //   start: const Duration(seconds: 60),
    //   end: const Duration(seconds: 90),
    //   child: AudioSource.uri(Uri.parse(
    //       "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3")),
    //   tag: MediaItem(
    //     id: '${_nextMediaId++}',
    //     album: "Science Friday",
    //     title: "A Salute To Head-Scratching Science (30 seconds)",
    //     artUri: Uri.parse(
    //         "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    //   ),
    // ),
    AudioSource.uri(
      Uri.parse(
          "https://drive.google.com/uc?export=download&id=1B5LuroUGnehb4Jcze7oeOq6mjwv5eWnA"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Yoasobi",
        title: "Ano Yume Wo Nazotte??????????????????????????????",
        artUri: Uri.parse(
            "https://drive.google.com/uc?export=download&id=1LqAE7_XObWSPi8HwhbyToVeWk0_JXFvv"),
      ),
    ),
    AudioSource.uri(
      Uri.parse(
          "https://drive.google.com/uc?export=download&id=1S7wsDu1_BRtyNCkEUIEIZB1hZ2ryVYkG"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Yoasobi",
        title: "Gonjou ????????????",
        artUri: Uri.parse(
            "https://drive.google.com/uc?export=download&id=1E4TtmFK--8r_BdZtVLoXfNlt2E4FzzKx"),
      ),
    ),
    AudioSource.uri(
      Uri.parse(
          "https://drive.google.com/uc?export=download&id=1wyPZ6Adh76g5WPf8ogtV2RDfbIPD5ebH"),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Yoasobi",
        title: "Monster????????????",
        artUri: Uri.parse(
            "https://drive.google.com/uc?export=download&id=1L2wy-3OdSN9SFpyzJHAwhC2nWpfgsUBH"),
      ),
    ),
    // AudioSource.uri(
    //   Uri.parse(
    //       "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
    //   tag: MediaItem(
    //     id: '${_nextMediaId++}',
    //     album: "Science Friday",
    //     title: "A Salute To Head-Scratching Science",
    //     artUri: Uri.parse(
    //         "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    //   ),
    // ),
    // AudioSource.uri(
    //   Uri.parse("https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3"),
    //   tag: MediaItem(
    //     id: '${_nextMediaId++}',
    //     album: "Science Friday",
    //     title: "From Cat Rheology To Operatic Incompetence",
    //     artUri: Uri.parse(
    //         "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    //   ),
    // ),
    // AudioSource.uri(
    //   Uri.parse("asset:///audio/nature.mp3"),
    //   tag: MediaItem(
    //     id: '${_nextMediaId++}',
    //     album: "Public Domain",
    //     title: "Nature Sounds",
    //     artUri: Uri.parse(
    //         "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
    //   ),
    // ),
  ]);

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAudioSource(_playlist);
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
      print(stackTrace);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        backgroundColor: mainColor,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<SequenceState?>(
                stream: _player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state?.sequence.isEmpty ?? true) {
                    return const SizedBox();
                  }
                  final metadata = state!.currentSource!.tag as MediaItem;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Image.network(metadata.artUri.toString())),
                        ),
                      ),
                      Text(metadata.album!,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(metadata.title),
                    ],
                  );
                },
              ),
            ),
            ControlButtons(_player),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    _player.seek(newPosition);
                  },
                );
              },
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                StreamBuilder<LoopMode>(
                  stream: _player.loopModeStream,
                  builder: (context, snapshot) {
                    final loopMode = snapshot.data ?? LoopMode.off;
                    const icons = [
                      Icon(Icons.repeat, color: Colors.grey),
                      Icon(Icons.repeat, color: Colors.orange),
                      Icon(Icons.repeat_one, color: Colors.orange),
                    ];
                    const cycleModes = [
                      LoopMode.off,
                      LoopMode.all,
                      LoopMode.one,
                    ];
                    final index = cycleModes.indexOf(loopMode);
                    return IconButton(
                      icon: icons[index],
                      onPressed: () {
                        _player.setLoopMode(cycleModes[
                            (cycleModes.indexOf(loopMode) + 1) %
                                cycleModes.length]);
                      },
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    "Playlist",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _player.shuffleModeEnabledStream,
                  builder: (context, snapshot) {
                    final shuffleModeEnabled = snapshot.data ?? false;
                    return IconButton(
                      icon: shuffleModeEnabled
                          ? const Icon(Icons.shuffle, color: Colors.orange)
                          : const Icon(Icons.shuffle, color: Colors.grey),
                      onPressed: () async {
                        final enable = !shuffleModeEnabled;
                        if (enable) {
                          await _player.shuffle();
                        }
                        await _player.setShuffleModeEnabled(enable);
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 240.0,
              child: StreamBuilder<SequenceState?>(
                stream: _player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) newIndex--;
                      _playlist.move(oldIndex, newIndex);
                    },
                    children: [
                      for (var i = 0; i < sequence.length; i++)
                        Dismissible(
                          key: ValueKey(sequence[i]),
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (dismissDirection) {
                            _playlist.removeAt(i);
                          },
                          child: Material(
                            color: i == state!.currentIndex
                                ? Colors.grey.shade300
                                : null,
                            child: ListTile(
                              title: Text(sequence[i].tag.title as String),
                              onTap: () {
                                _player.seek(Duration.zero, index: i);
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        backgroundColor: mainColor,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.symmetric(vertical: 40.0),
          children: [
            // const DrawerHeader(
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            //   child: Text('Drawer Header'),
            // ),
            ListTile(
              selected: true,
              selectedTileColor: Color.fromARGB(255, 43, 43, 43),
              textColor: Colors.white,
              selectedColor: Colors.white,
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              selectedTileColor: Color.fromARGB(255, 43, 43, 43),
              textColor: Colors.white,
              selectedColor: Colors.white,
              leading: const Icon(Icons.search, color: Colors.white),
              title: const Text('Search'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              selectedTileColor: Color.fromARGB(255, 43, 43, 43),
              textColor: Colors.white,
              selectedColor: Colors.white,
              leading: Icon(Icons.playlist_play, color: Colors.white),
              title: const Text('Recently Played'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              selectedTileColor: Color.fromARGB(255, 43, 43, 43),
              textColor: Colors.white,
              selectedColor: Colors.white,
              leading: Icon(Icons.queue_music, color: Colors.white),
              title: const Text('Playlists'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              selectedTileColor: Color.fromARGB(255, 43, 43, 43),
              textColor: Colors.white,
              selectedColor: Colors.white,
              leading: Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Create Playlists'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              selectedTileColor: Color.fromARGB(255, 43, 43, 43),
              textColor: Colors.white,
              selectedColor: Colors.white,
              leading: Icon(Icons.favorite, color: Colors.white),
              title: const Text('Liked Songs'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices!.first),
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {},
        ),
        // TODO: hide adjust speed feature
        // StreamBuilder<double>(
        //   stream: player.speedStream,
        //   builder: (context, snapshot) => IconButton(
        //     icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
        //         style: const TextStyle(fontWeight: FontWeight.bold)),
        //     onPressed: () {
        //       showSliderDialog(
        //         context: context,
        //         title: "Adjust speed",
        //         divisions: 10,
        //         min: 0.5,
        //         max: 1.5,
        //         stream: player.speedStream,
        //         onChanged: player.setSpeed,
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}
