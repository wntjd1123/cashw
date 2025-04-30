import 'package:flutter/material.dart';
import 'run_segment.dart';
import 'Walkingrunningpage.dart';

class StressReliefRunningDetailPage extends StatefulWidget {
  const StressReliefRunningDetailPage({super.key});
  @override
  State<StressReliefRunningDetailPage> createState()=>_StressReliefRunningDetailPageState();
}

class _StressReliefRunningDetailPageState extends State<StressReliefRunningDetailPage>{
  bool stretchOn=true,coolOn=true;
  List<RunSegment> _segs()=>[
    if(stretchOn)RunSegment('스트레칭',6*60),
    RunSegment('달리기',30*60,mandatory:true),
    if(coolOn)RunSegment('쿨다운',2*60),
  ];

  @override Widget build(BuildContext c)=>Scaffold(
      appBar:AppBar(title:const Text('스트레스 해소 러닝',style:TextStyle(color:Colors.black)),
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
                      builder:(_)=>WalkingRunningPage(modeTitle:'스트레스 해소 러닝',segments:_segs()))); },
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
          const Icon(Icons.self_improvement,color:Colors.deepOrange),
          const SizedBox(width:8),
          const Expanded(child:Text('스트레스 해소 러닝',style:TextStyle(fontWeight:FontWeight.bold))),
          const Text('38분',style:TextStyle(fontWeight:FontWeight.bold)),
        ]),
        const SizedBox(height:12),
        const Text('오늘 하루 너무 수고 많으셨어요! 우울하거나 힘든 일, 화난 일 등 여러가지 스트레스를 러닝으로 풀어보아요! '
            '러닝크루가 여러분이 즐거운 하루를 마무리할 수 있도록 언제나 응원해드릴게요!'),
        const Divider(height:32),
        const Text('프로그램 구성',style:TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:12),
        _row('스트레칭 6분',stretchOn,(v)=>setState(()=>stretchOn=v)),
        _row('달리기 30분',true,null,mandatory:true),
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
