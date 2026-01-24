import 'package:flutter/material.dart';
import 'Services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'sign.dart';
class login extends StatelessWidget{
  final TextEditingController emailcontroller = TextEditingController();
   final TextEditingController passwordcontroller = TextEditingController();
  @override

  Widget build(BuildContext context){
    return Scaffold(
         appBar:AppBar(
          backgroundColor: Colors.purple,
          title:Text("The Budget App",style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,
          color:const Color.fromARGB(255, 245, 233, 247)),)
         ),

         body:Form(
          child:Padding(
          
          padding:EdgeInsets.all(10.0),
          
           child: CircleAvatar(
            
            backgroundImage: AssetImage("assets/images/logo.jpeg"),
            radius:40
           ),
         
          ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("TrackFunds",style:TextStyle(fontSize:35,fontWeight:FontWeight.bold),textAlign:TextAlign.center),
         SizedBox(height:10),
         Text("Spend Wisely, Save ffortlessly",style:TextStyle(fontSize:20,fontStyle:FontStyle.italic),textAlign:TextAlign.center),
            
            Padding(padding: EdgeInsets.all(5)),
            Text('LOGIN',style:TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
            TextFormField(
              controller:emailcontroller,
              decoration:InputDecoration(
                labelText:"email",
                prefixIcon:Icon(Icons.person),
                border:OutlineInputBorder(borderRadius: BorderRadius.circular(20)))
              ,
              validator:(value){
                if(value == null||value.isEmpty){
                   return("please enter email");
                }
                return null;
              }
            
            
            
            ),
            
                     SizedBox(height:15),
            
            TextFormField(
              controller: passwordcontroller,
              decoration:InputDecoration(
                labelText:"Password",
                prefixIcon:Icon(Icons.lock),
                border:OutlineInputBorder(borderRadius: BorderRadius.circular(20))
              ),
              validator:(value){
                if(value ==null||value.isEmpty){
                  return("please enter valid password");
                }
                if (value.length<8){
                  return("Password must beatleast 8 characters");
                }
                
                return null;
              }
            ),
            SizedBox(height: 15,),
            ElevatedButton(
              
              onPressed:()async{
                final email = emailcontroller.text;
                final password =passwordcontroller.text;

                final Result = await AuthService.login(email, password);

                if (Result['statusCode'==201]){
                  Navigator.pushNamed(context,'/navbar');
                }
                else{
                  final error = Result['body'];
                  ScaffoldMessenger.of(context).
                    showSnackBar(
                      SnackBar(content:Text(error.toString()))
                    );
                }
              },
              child:Text("LOG IN",style:TextStyle(color:Colors.purple,)),
            ),
             SizedBox(height:15),
            RichText(
              text:TextSpan(
                style: const TextStyle(color:Colors.black, fontSize:16),
                children:[
                      const TextSpan(text:"Don't have an Account?  "),
                     
                      TextSpan(
                       text:"Create Account",
                       style:const TextStyle(
                        color:Colors.purple,
                        fontWeight:FontWeight.bold,
                        decoration:TextDecoration.underline,
                       ),
                       recognizer:TapGestureRecognizer()
                                   ..onTap = (){
                                    Navigator.push(context, 
                                    MaterialPageRoute(builder:(context)=>  Sign()));
                                   }
                      )
                ]
              )
            )






                     ],),
          )
    ));
  }

}