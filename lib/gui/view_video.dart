import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class ViewVideo extends StatefulWidget{
  ViewVideo(this.theVideoId);
  String theVideoId;


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewVideoState(this.theVideoId);
  }

}

class _ViewVideoState extends State<ViewVideo> {
  _ViewVideoState(this.theVideoId);
  String theVideoId;

  late List<YoutubePlayerController> _controllers;

  @override
  void initState(){
    super.initState();

    _controllers = [
      theVideoId,
    ].map<YoutubePlayerController>(
          (videoId) => YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
        ),
      ),
    ).toList();
  }




  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 100.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return YoutubePlayer(
              key: ObjectKey(_controllers[index]),
              controller: _controllers[index],
              actionsPadding: const EdgeInsets.only(left: 16.0),
              bottomActions: [
                CurrentPosition(),
                const SizedBox(width: 10.0),
                ProgressBar(isExpanded: true),
                const SizedBox(width: 10.0),
                RemainingDuration(),
                FullScreenButton(),
              ],
            );
          },
          itemCount: _controllers.length,
          separatorBuilder: (context, _) => const SizedBox(height: 10.0),
        ),
      ),
    );
  }

}
