import 'dart:math';

// 0 rock, 1 paper, 2 scissors. The second gesture defeats the first.
int rpsResult(int player,int opponent){if(player<0||player>2||opponent<0||opponent>2)throw ArgumentError('Invalid gesture');return player==opponent?0:(player-opponent+3)%3==1?1:-1;}
int chooseGesture(List<int> history,bool predictive,Random random){if(!predictive||history.isEmpty||random.nextDouble()<0.25)return random.nextInt(3);final counts=List.filled(3,1);for(final value in history.skip(max(0,history.length-20))){counts[value]++;}final high=counts.reduce(max);final tied=[for(int i=0;i<3;i++)if(counts[i]==high)i];return (tied[random.nextInt(tied.length)]+1)%3;}
class RpsMatch {
  int player=0,opponent=0;final List<List<int>> rounds=[];
  bool get over=>player>=3||opponent>=3;
  bool add(int a,int b){if(over)return false;final r=rpsResult(a,b);rounds.add([a,b,r]);if(r==1)player++;if(r==-1)opponent++;return true;}
  Map<String,dynamic> toJson()=>{'version':1,'rounds':rounds};
  static RpsMatch? fromJson(Map<String,dynamic> j){try{if(j['version']!=1)return null;final m=RpsMatch();for(final row in j['rounds'] as List){final r=List<int>.from(row as List);if(r.length!=3||rpsResult(r[0],r[1])!=r[2]||!m.add(r[0],r[1]))return null;}return m;}catch(_){return null;}}
}
