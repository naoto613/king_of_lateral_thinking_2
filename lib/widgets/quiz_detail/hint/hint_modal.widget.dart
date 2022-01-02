import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:king_of_lateral_thinking_2/models/quiz.model.dart';
import 'package:king_of_lateral_thinking_2/providers/common.provider.dart';
import 'package:king_of_lateral_thinking_2/services/admob/reward_action.service.dart';
import 'package:king_of_lateral_thinking_2/widgets/common/comment_modal.widget.dart';
import 'package:king_of_lateral_thinking_2/widgets/common/loading_modal.widget.dart';
import 'package:king_of_lateral_thinking_2/widgets/common/modal_do_not_watch_button.widget.dart';

class HintModal extends HookWidget {
  final BuildContext screenContext;
  final Quiz quiz;
  final TextEditingController subjectController;
  final TextEditingController relatedWordController;
  final int workHintValue;

  const HintModal({
    Key? key,
    required this.screenContext,
    required this.quiz,
    required this.subjectController,
    required this.relatedWordController,
    required this.workHintValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AudioCache soundEffect = useProvider(soundEffectProvider).state;
    final double seVolume = useProvider(seVolumeProvider).state;

    final ValueNotifier<RewardedAd?> rewardedAd = useState(null);

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            workHintValue < 3
                ? (quiz.id == 1 ? '短い動画を見ずにヒント' : '短い動画を見てヒント') +
                    (workHintValue + 1).toString() +
                    'を取得しますか？'
                : 'ヒントはもうありません。',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'SawarabiGothic',
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                workHintValue < 1 ? Icons.looks_one_outlined : Icons.looks_one,
                size: 45,
              ),
              Icon(
                workHintValue < 2 ? Icons.looks_two_outlined : Icons.looks_two,
                size: 45,
              ),
              Icon(
                workHintValue < 3 ? Icons.looks_3_outlined : Icons.looks_3,
                size: 45,
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            workHintValue == 0
                ? '主語と関連語を選択肢で選べるようになります。'
                : workHintValue == 1
                    ? '質問を選択肢で選べるようになります。'
                    : workHintValue == 2
                        ? '正解を導く質問のみ選べるようになります。'
                        : 'もう答えはすぐそこです！',
            style: const TextStyle(
              fontSize: 18.0,
              fontFamily: 'SawarabiGothic',
            ),
          ),
          quiz.id == 1 && workHintValue < 3
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '※問1は動画を見ずにヒントを取得できます！',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'SawarabiGothic',
                      color: Colors.orange.shade900,
                    ),
                  ),
                )
              : Container(),
          const SizedBox(height: 15),
          Wrap(
            children: [
              const ModalDoNotWatchButton(),
              const SizedBox(width: 30),
              SizedBox(
                width: 70,
                height: 40,
                child: ElevatedButton(
                  child: const Text('見る'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade600,
                    padding: const EdgeInsets.only(
                      bottom: 2,
                    ),
                    shape: const StadiumBorder(),
                    side: BorderSide(
                      width: 2,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  onPressed: workHintValue < 3
                      ? quiz.id == 1
                          ? () {
                              soundEffect.play(
                                'sounds/tap.mp3',
                                isNotification: true,
                                volume: seVolume,
                              );
                              Navigator.pop(context);
                              afterGotHint(
                                screenContext,
                                quiz,
                                subjectController,
                                relatedWordController,
                              );
                            }
                          : () async {
                              soundEffect.play(
                                'sounds/tap.mp3',
                                isNotification: true,
                                volume: seVolume,
                              );
                              // ロード中モーダルの表示
                              showDialog<int>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const LoadingModal();
                                },
                              );
                              // 広告のロード
                              await rewardLoading(
                                rewardedAd,
                                2,
                              );
                              if (rewardedAd.value != null) {
                                showHintRewardedAd(
                                  screenContext,
                                  rewardedAd,
                                  quiz,
                                  subjectController,
                                  relatedWordController,
                                );
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.NO_HEADER,
                                  headerAnimationLoop: false,
                                  dismissOnTouchOutside: true,
                                  dismissOnBackKeyPress: true,
                                  showCloseIcon: true,
                                  animType: AnimType.SCALE,
                                  width:
                                      MediaQuery.of(context).size.width * .86 >
                                              550
                                          ? 550
                                          : null,
                                  body: const CommentModal(
                                    topText: '取得失敗',
                                    secondText:
                                        '動画の読み込みに失敗しました。\n電波の良いところで再度お試しください。',
                                    closeButtonFlg: true,
                                  ),
                                ).show();
                              }
                            }
                      : () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
