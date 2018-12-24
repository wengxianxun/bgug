import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/flame.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../ads.dart';
import '../data.dart';
import 'gui_commons.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  String username = '-';

  _HomeScreenState() {
    var ps = <Future>[
      Ad.startup(),
      SystemChrome.setEnabledSystemUIOverlays([]),
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]),
      Flame.audio.loadAll([
        'death.wav',
        'gem_collect.wav',
        'jump.wav',
        'laser_load.wav',
        'laser_shoot.wav',
        'music.wav',
      ]).then((audios) => print('Done loading ' + audios.length.toString() + ' audios.')),
      Flame.images.loadAll([
        'hud_bg.png',
        'btns/coin.png',
        'btns/player_1.png',
        'btns/player_2.png',
        'player_1.png',
        'player_2.png',
        'base_bottom.png',
        'base_top.png',
        'block.png',
        'obstacle.png',
        'shooter.png',
        'bullet.png',
        'gem.png',
        'coin.png',
        'coin_button.png',
        'bg.png',
        'button.png',
        'endgame_bg.png',
        'endgame_buttons.png',
        'tutorial.png',
        'splash_screen.png',
      ]).then((images) => print('Done loading ' + images.length.toString() + ' images.')),
      Data.loadAll(),
    ];
    Future.wait(ps).then((rs) => this.setState(() => loading = false));
    // _handleSignIn();
    username = 'test user';
  }

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('signed in ${user.displayName}');
    setState(() => username = user.displayName);
    return user;
  }

  addToScore(String newScore) async {
    Data.score.scores.add(newScore);
    Data.score.save();
  }

  redraw() {
    this.setState(() => {});
  }

  Widget userCard() {
    return new Text(username);
  }

  Widget coin() {
    final stack = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset('assets/images/coin_button.png'),
        Positioned(child: Text(Data.buy.coins.toString()), bottom: 2.0),
      ],
    );
    return GestureDetector(
      child: stack,
      onTap: () => Navigator.of(context).pushNamed('/buy'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF404040),
        ),
        child: Image.asset(
          "assets/images/splash_screen.png",
          fit: BoxFit.contain,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      );
    }

    final child = Center(
      child: Row(
        children: [
          Column(
            children: [
              pad(Text('BLOCK', style: title), 2.0),
              pad(Text('guns', style: title), 2.0),
              pad(Text('USING', style: title), 2.0),
              pad(Text('gems', style: title), 2.0),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Column(
            children: [
              btn('Play', () => Navigator.of(context).pushNamed('/start')),
              btn('Score', () => Navigator.of(context).pushNamed('/score')),
              btn('Options', () => Navigator.of(context).pushNamed('/options')),
              btn('Exit', () => SystemNavigator.pop()),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          child,
          Positioned(child: coin(), top: 12.0, right: 12.0),
          Positioned(child: userCard(), bottom: 12.0, left: 12.0),
        ],
      ),
    );
  }
}
