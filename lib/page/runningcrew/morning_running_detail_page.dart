import 'package:flutter/material.dart';
import 'run_segment.dart';
import 'Walkingrunningpage.dart';

class MorningRunningDetailPage extends StatefulWidget {
  const MorningRunningDetailPage({super.key});
  @override
  State<MorningRunningDetailPage> createState()=>_MorningRunningDetailPageState();
}

class _MorningRunningDetailPageState extends State<MorningRunningDetailPage>{
  bool stretchOn=true,coolOn=true;
  List<RunSegment> _segs()=>[
    if(stretchOn)RunSegment('스트레칭',6*60),
    RunSegment('천천히 걷기',5*60,mandatory:true),
    RunSegment('빨리 걷기',5*60,mandatory:true),
    RunSegment('천천히 달리기',10*60,mandatory:true),
    RunSegment('빨리 달리기',10*60,mandatory:true),
    if(coolOn)RunSegment('쿨다운',2*60),
  ];

  @override Widget build(BuildContext c)=>Scaffold(
      appBar:AppBar(title:const Text('아침 러닝',style:TextStyle(color:Colors.black)),
          centerTitle:true,backgroundColor:Colors.white,
          iconTheme:const IconThemeData(color:Colors.black)),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        ClipRRect(borderRadius:BorderRadius.circular(12),
            child:Image.asset('assets/images/tree.png',height:200,fit:BoxFit.cover)),
        const SizedBox(height:16),
        const Text('러닝 단계 설정',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
        const SizedBox(height:16),
        _card(),
        const SizedBox(height:80),
      ]),
      bottomNavigationBar:Padding(
          padding:const EdgeInsets.all(16),
          child:SizedBox(height:50,
              child:ElevatedButton(
                  onPressed:(){ Navigator.push(c,MaterialPageRoute(
                      builder:(_)=>WalkingRunningPage(modeTitle:'아침 러닝',segments:_segs()))); },
                  style:ElevatedButton.styleFrom(backgroundColor:Colors.deepOrange,
                      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8))),
                  child:const Text('운동 시작',style:TextStyle(fontSize:16,color:Colors.white))))));

  Widget _card()=>Container(
      padding:const EdgeInsets.all(16),
      decoration:BoxDecoration(
          border:Border.all(color:Colors.grey.shade300,width:2),
          borderRadius:BorderRadius.circular(12)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          const Icon(Icons.wb_sunny,color:Colors.deepOrange),
          const SizedBox(width:8),
          const Expanded(child:Text('아침 러닝',style:TextStyle(fontWeight:FontWeight.bold))),
          const Text('38분',style:TextStyle(fontWeight:FontWeight.bold)),
        ]),
        const SizedBox(height:12),
        const Text('좋은 아침이에요! 아침을 맑게 깨워줄 러닝을 러닝크루가 준비했어요! '
            '공복 유산소를 통해 나의 건강도 챙기고 상쾌한 아침도 일깨워볼까요?'),
        const Divider(height:32),
        const Text('프로그램 구성',style:TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:12),
        _row('스트레칭 6분',stretchOn,(v)=>setState(()=>stretchOn=v)),
        _row('천천히 걷기 5분',true,null,mandatory:true),
        _row('빨리 걷기 5분',true,null,mandatory:true),
        _row('천천히 달리기 10분',true,null,mandatory:true),
        _row('빨리 달리기 10분',true,null,mandatory:true),
        _row('쿨다운 2분',coolOn,(v)=>setState(()=>coolOn=v)),
      ]));

  Widget _row(String l,bool v,Function(bool)? cb,{bool mandatory=false})=>Row(
      mainAxisAlignment:MainAxisAlignment.spaceBetween,
      children:[ Text(l),
        mandatory?_pill('필수')
            :Switch(value:v,activeColor:Colors.deepOrange,onChanged:cb),]);

  Widget _pill(String t)=>Container(
      padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),
      decoration:BoxDecoration(color:Colors.deepOrange.withOpacity(.12),
          borderRadius:BorderRadius.circular(4)),
      child:Text(t,style:const TextStyle(fontSize:12,color:Colors.deepOrange)));
}
