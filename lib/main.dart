import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';


void main() {
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
      ),
      home:  MaskDetectionApp(),
    );
  }
}
class MaskDetectionApp extends StatefulWidget {
  const MaskDetectionApp({Key? key}) : super(key: key);

  @override
  State<MaskDetectionApp> createState() => _MaskDetectionAppState();
}

class _MaskDetectionAppState extends State<MaskDetectionApp> {
   bool _loading=true;
  late File _image;
  final imagepicker=ImagePicker();
  List _predictions=[];

   void initState() {
     super.initState();
     loadmodel().then((value) {
       setState(() {});
     });
   }
  loadmodel() async{
    await Tflite.loadModel(model:'assets/model_unquant.tflite',labels:'assets/labels.txt');

  }
  detect_mask(File image) async{
    var prediction=await Tflite.runModelOnImage(
      path:image.path,
      numResults:2,
      threshold:0.6,
      imageMean:127.5,
      imageStd:127.5
    );
    setState(() {
      _loading=false;
      _predictions=prediction!;
    });
  }
  void dispose(){
    super.dispose();
  }

  _loadimage_gallery() async{
    var image=await imagepicker.pickImage(source: ImageSource.gallery);
    if(image==null){
      return null;
    }
    else{
    //   setState((){
    //     _loading=false;
    //   });
      _image=File(image.path);
    }
    detect_mask(_image);
  }

  _loadimage_camera() async{
    var image=await imagepicker.pickImage(source: ImageSource.camera);
    if(image==null){
      return null;
    }
    else{
    //   setState((){
    //     _loading=false;
    //   });
      _image=File(image.path);
    }
    detect_mask(_image);
  }


  @override
  Widget build(BuildContext context) {
    var h=MediaQuery.of(context).size.height;
    var w=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Mask Detection App",style:GoogleFonts.balooBhai2(fontSize: 25,fontWeight: FontWeight.bold)),),
    body: Container(
      height: h,
        width: w,
      color: Colors.redAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,width: 200,padding: EdgeInsets.all(10),
            child: Image.asset("assets/mask.png"),
          ),
          Container(
            child: Text("ML Mask Detection",style: GoogleFonts.balooBhai2(fontWeight: FontWeight.bold,fontSize: 30),),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 70,
            padding: EdgeInsets.all(10),
            child: ElevatedButton(onPressed: (){
              _loadimage_camera();
            },
              // color: Colors.teal,
              child: Text("Camera",style: GoogleFonts.balooBhai2(fontSize: 20,fontWeight: FontWeight.w500),),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 70,
            padding: EdgeInsets.all(10),
            child: ElevatedButton(onPressed: (){
              _loadimage_gallery();
            },
              // color: Colors.teal,
              child: Text("Gallery",style: GoogleFonts.balooBhai2(fontSize: 20,fontWeight: FontWeight.w500),),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
            ),
          ),
          SizedBox(height: 10,),
          _loading==false?
          Column(
            children: [
              Container(
                height: 220,width: 200,child: Image.file(_image),
              ),
              Text(_predictions[0]['label'].toString().substring(2),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              Text("Confidence:"+_predictions[0]['confidence'].toString()),
            ],
          ):Container(),
        ],
      ),
    ),
    );
  }
}


