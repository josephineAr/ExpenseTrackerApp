import 'package:flutter/material.dart';
import 'Services/auth_service.dart';
import 'login.dart';
import 'package:flutter/gestures.dart';
class Sign extends StatelessWidget{
  final TextEditingController usernamecontroller = TextEditingController();
   final TextEditingController emailcontroller = TextEditingController();
    final TextEditingController passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context){
     return Scaffold(
      body:Form(child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
          Text("Sign Up",style:TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:Colors.purple)),
          Padding(padding:EdgeInsets.all(4)),
          TextFormField(
            controller:usernamecontroller,
            decoration:InputDecoration(
              hintText:"Enter Username",
              labelText:"Username",
              prefixIcon:Icon(Icons.person),
              border:OutlineInputBorder()
            ),
            validator:(value){
              if(value==null||value.isEmpty){
                return "Please enter Username";
              }
              return null;
            }
          ),SizedBox(height:15),
        
        TextFormField(
          controller: emailcontroller,
          decoration:InputDecoration(
            hintText:"Enter Email",
            labelText:"Email",
            prefixIcon:Icon(Icons.email),
            border:OutlineInputBorder()
           ),
           validator:(value){
            if(value ==null||value.isEmpty){
              return "Please Enter Email";
            }
            // if (!value.contains(@)){
            //   return "Please enter valid Email";
            // }
             return null;
           }
        ),SizedBox(height:15),
        TextFormField(
          controller: passwordcontroller,
          decoration:InputDecoration(
            hintText:"Enter Password",
            labelText:"Password",
            prefixIcon:Icon(Icons.lock),
            border:OutlineInputBorder(borderRadius:BorderRadius.circular(20))
           ),
           validator:(value){
            if(value ==null||value.isEmpty){
              return "Please Enter Password";
            }
            if (value.length<8){
              return "Password must be atleast 8  characters";
            }
             return null;
           }
        ),SizedBox(height:15),
        ElevatedButton(
          
          onPressed:()async {
            final username=usernamecontroller.text;
            final email =emailcontroller.text;
            final password=passwordcontroller.text;

            final Result = await AuthService.signup(username,email,password);

            if(Result['statusCode'] ==201){
              Navigator.pushNamed(context,'/login');
            }
            else{
              final error = Result['body'];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.toString()),)
                );
            }
          },
          child:Text("SIGN-UP",style:TextStyle(fontSize:20,color:Colors.purple)),
        ),
        SizedBox(height:10),
        RichText(
          text:TextSpan(
             text:("Already Have An Account!  "),
             style:const TextStyle(color:Colors.black),

            children: [
             TextSpan(
              text:"Log In",
              style:const TextStyle(color:Colors.purple,
              fontWeight:FontWeight.bold,
              decoration:TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(context,
                           MaterialPageRoute(builder:(context)=> login()));
                        }
             )
            ]
          )
        )
        ],),
      ),)
     );
  }
}