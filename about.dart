import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: SingleChildScrollView(
          child: Column(children: [
            CircleAvatar(
              //logo
             backgroundImage:  AssetImage("assets/images/logo.jpeg"),
              radius:40
            ),
            Text("TrackFunds",style: TextStyle(fontWeight:FontWeight.bold,fontSize:25),),
            SizedBox(
            height:25
          ),
          Text("AppVersion:0.0.1",style:TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height:25
          ),
            Text("call the Developer: 0770947655",style:TextStyle(fontWeight:FontWeight.bold)),
              SizedBox(
            height:25
          ),
           
          ],),
        ),
      )
    );
  }
}