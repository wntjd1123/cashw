import 'package:flutter/material.dart';
import 'run_segment.dart';
import 'Walkingrunningpage.dart';

class _RunMode {
  final String title, sub, detail;
  final List<RunSegment> segments;
  const _RunMode(this.title, this.sub, this.detail, this.segments);
}

final List<_RunMode> _modes = [
  _RunMode('3분 단거리 러닝','러닝 맛보기 운동 시작!','짧지만 효과는 충분합니다!',[
    RunSegment('스트레칭',4*60,mandatory:false),
    RunSegment('달리기',3*60,mandatory:true),
    RunSegment('쿨다운',5*60,mandatory:false),
  ]),
  _RunMode('5분 단거리 러닝','짧지만 러닝효과 가득!','짧지만 효과는 충분합니다!',[
    RunSegment('스트레칭',4*60,mandatory:false),
    RunSegment('달리기',5*60,mandatory:true),
    RunSegment('쿨다운',5*60,mandatory:false),
  ]),
  _RunMode('15분 중거리 러닝','러닝이 익숙해졌다면 도전!','인터벌 러닝으로 효과 Up!',[
    RunSegment('스트레칭',4*60,mandatory:false),
    RunSegment('걷기',3*60,mandatory:true),
    RunSegment('달리기',5*60,mandatory:true),
    RunSegment('걷기',3*60,mandatory:true),
    RunSegment('달리기',4*60,mandatory:true),
    RunSegment('쿨다운',1*60,mandatory:false),
  ]),
  _RunMode('30분 장거리 러닝','전문 러너로 달려보기!','30분 러닝을 통해 매일 건강한 하루를!',[
    RunSegment('스트레칭',6*60,mandatory:false),
    RunSegment('걷기',3*60,mandatory:true),
    RunSegment('달리기',5*60,mandatory:true),
    RunSegment('걷기',3*60,mandatory:true),
    RunSegment('달리기',5*60,mandatory:true),
    RunSegment('걷기',3*60,mandatory:true),
    RunSegment('달리기',4*60,mandatory:true),
    RunSegment('걷기',3*60,mandatory:true),
    RunSegment('달리기',4*60,mandatory:true),
    RunSegment('쿨다운',2*60,mandatory:false),
  ]),
];

class RunningSkillDetailPage extends StatefulWidget {
  final int? initialMode;                  // ★ 추가
  const RunningSkillDetailPage({super.key, this.initialMode});
  @override State<RunningSkillDetailPage> createState()=>_RunningSkillDetailPageState();
}

class _RunningSkillDetailPageState extends State<RunningSkillDetailPage>{
  int selected=-1;
  @override void initState(){
    super.initState();
    if(widget.initialMode!=null) selected=widget.initialMode!;
  }

  @override Widget build(BuildContext c)=>Scaffold(
      appBar:AppBar(
          title:const Text('러닝 실력 향상',style:TextStyle(color:Colors.black)),
          centerTitle:true, backgroundColor:Colors.white,
          iconTheme:const IconThemeData(color:Colors.black)),
      body:ListView(
          padding:const EdgeInsets.all(16),
          children:[
            ClipRRect(borderRadius:BorderRadius.circular(12),
                child:Image.asset('assets/images/tree.png',height:180,fit:BoxFit.cover)),
            const SizedBox(height:16),
            const Text('러닝 단계 설정',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
            const SizedBox(height:16),
            for(int i=0;i<_modes.length;i++) _card(i,_modes[i]),
            const SizedBox(height:80),
          ]),
      bottomNavigationBar:Padding(
          padding:const EdgeInsets.all(16),
          child:SizedBox(height:50,
              child:ElevatedButton(
                  onPressed:selected==-1?null:(){
                    final m=_modes[selected];
                    Navigator.push(c,MaterialPageRoute(
                        builder:(_)=>WalkingRunningPage(
                          modeTitle:m.title,
                          segments:List<RunSegment>.from(m.segments),
                        )));
                  },
                  style:ElevatedButton.styleFrom(
                      backgroundColor:selected==-1?Colors.grey[300]:Colors.deepOrange),
                  child:const Text('운동 시작',
                      style:TextStyle(fontSize:16,color:Colors.white))))) );

  Widget _card(int i,_RunMode m){
    final open=selected==i;
    return GestureDetector(
        onTap:()=>setState(()=>selected=open?-1:i),
        child:Container(
            margin:const EdgeInsets.only(bottom:12),
            decoration:BoxDecoration(
                color:open?Colors.deepOrange.withOpacity(.05):Colors.white,
                border:Border.all(color:open?Colors.deepOrange:Colors.grey.shade300,width:2),
                borderRadius:BorderRadius.circular(16)),
            child:Column(children:[
              ListTile(
                  title:Text(m.title,style:const TextStyle(fontWeight:FontWeight.bold)),
                  subtitle:Text(m.sub),
                  trailing:Text('${m.segments.fold<int>(0,(p,s)=>p+s.seconds~/60)}분',
                      style:const TextStyle(fontWeight:FontWeight.bold))),
              if(open) _detail(m),
            ])));
  }

  Widget _detail(_RunMode m)=>Padding(
      padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),
      child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children:[
            Text(m.detail),
            const SizedBox(height:12),
            const Text('프로그램 구성',style:TextStyle(fontWeight:FontWeight.bold)),
            const Divider(),
            for(final s in m.segments) _row(s),
          ]));

  Widget _row(RunSegment s)=>Row(
      mainAxisAlignment:MainAxisAlignment.spaceBetween,
      children:[
        Text('${s.label} ${s.seconds~/60}분'),
        s.mandatory
            ? Container(
          padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),
          decoration:BoxDecoration(color:Colors.deepOrange.withOpacity(.12),
              borderRadius:BorderRadius.circular(4)),
          child:const Text('필수',style:TextStyle(fontSize:12,color:Colors.deepOrange)),
        )
            : Switch(value:s.enabled,activeColor:Colors.deepOrange,
            onChanged:(v)=>setState(()=>s.enabled=v)),
      ]);
}
