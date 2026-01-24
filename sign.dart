import 'package:flutter/material.dart';
import 'Services/auth_service.dart';
import 'login.dart';
import 'package:flutter/gestures.dart';
class Sign extends StatefulWidget{
  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> {
  final TextEditingController namecontroller = TextEditingController();

   final TextEditingController emailcontroller = TextEditingController();

   bool _isObscured = true;

    final TextEditingController passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context){
     return Scaffold(
      appBar:AppBar(
        backgroundColor:Colors.purple,
        title:Text("TrackFunds", style:TextStyle(fontWeight:FontWeight.bold,fontSize:15,color:Colors.white))
      ),
      body:SingleChildScrollView(
        child: Form(child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              CircleAvatar(
              
              backgroundImage: AssetImage("assets/images/logo.jpeg"),
              radius:40
             ),
           
            
                  Text("TrackFunds",style:TextStyle(fontSize:35,fontWeight:FontWeight.bold),textAlign:TextAlign.center),
           
           Text("Spend Wisely, Save ffortlessly",style:TextStyle(fontSize:20,fontStyle:FontStyle.italic),textAlign:TextAlign.center),
            SizedBox(height:15),
            Text("Sign Up",style:TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:Colors.purple)),
            Padding(padding:EdgeInsets.all(4)),
            TextFormField(
              controller:namecontroller,
              
              decoration:InputDecoration(
                hintText:"Enter Username",
                labelText:"Username",
                prefixIcon:Icon(Icons.person),
                border:OutlineInputBorder(),
                
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
            obscureText:_isObscured,
            decoration:InputDecoration(
              hintText:"Enter Password",
              labelText:"Password",
              prefixIcon:Icon(Icons.lock),
              border:OutlineInputBorder(borderRadius:BorderRadius.circular(20)),
              suffixIcon:IconButton(
                  icon:Icon(_isObscured?
                  Icons.visibility_off:Icons.visibility,),
                  onPressed:(){
                    setState((){
                      _isObscured = !_isObscured;
                    });
                  }
                )),
             
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
            
           onPressed: () async {
          final username = namecontroller.text;
          final email = emailcontroller.text;
          final password = passwordcontroller.text;
        
          try {
            final result = await AuthService.signup(username, email, password);
        
         
            if (result['statusCode'] == 201 || result['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created! Please Login"), backgroundColor: Colors.green)
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => login())
        );
            } else {
       
        final errorMessage = result['body'] is Map 
            ? result['body']['message'] 
            : result['body'].toString();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? "Signup failed"),
            backgroundColor: Colors.purple,
          )
        );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error"), backgroundColor: Colors.purple)
            );
          }
          
        },
        child:Text("SIGN UP",style:TextStyle(color:Colors.purple,)),),
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
        ),),
      )
     );
  }
}