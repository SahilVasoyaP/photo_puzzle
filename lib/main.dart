import 'dart:typed_data';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';

void main(){
  runApp(MaterialApp(
debugShowCheckedModeBanner: false,
    home:first(),
  ));
}
class first extends StatefulWidget {
  const first({Key? key}) : super(key: key);

  @override
  State<first> createState() => _firstState();
}
class _firstState extends State<first> {
  List<Image> imglist=[];
  List<Image> trimglist=[];

  List<Image> splitImage(List<int> input) {
    // convert image to image from image package
    imglib.Image? image = imglib.decodeImage(input);
    int x = 0, y = 0;
    int width = (image!.width / 3).round();
    int height = (image.height / 3).round();
    // split image to parts
    List<imglib.Image> parts = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }

    // convert image from image package to Image Widget to display
    List<Image> output = [];
    for (var img in parts) {
      output.add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
    }
    return output;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');
    var directory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)+"/myimage";
    Directory d=Directory(directory);
    if(await d.exists())
      {
       await d.create();
      }
    final file = File('${d.path}/img.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  @override
  void initState() {
  createimage();

  }
  createimage() async {
    var status = await Permission.storage.status;
    if(status.isDenied)
    {
      await[Permission.storage].request();
    }
    //asset file
    File f = await getImageFileFromAssets('images/sqim.jpg');
//file to list<int>
List<int> intimglist= await f.readAsBytes();
  // split image
    imglist=await splitImage(intimglist);
    trimglist.addAll(imglist);
  imglist.shuffle();
setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Picture Puzzle",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),)),backgroundColor: Colors.black,),
    body: Column(
      children: [
        Text("Task",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
        Center(
          child: Container(
            height: 100,
            width: 100,
            child: Image.asset("images/sqim.jpg"),
          ),
        ),
        Container(
          height: 350,
          width: double.infinity,
          color: Colors.grey,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(itemCount: imglist.length,itemBuilder: (context, index) {
              return DragTarget(onAccept: (int data) {
                setState(() {
                  Image temp;
                  temp=imglist[data];
                  imglist[data]=imglist[index];
                  imglist[index]=temp;
                });
                if(listEquals(trimglist, imglist))
                  {
                    showDialog(builder: (context) {
                      return AlertDialog(
                        title: Text("you are Win........"),
                      );

                    },context: context);
                  }
              },builder: (context, candidateData, rejectedData) {
                return Draggable(
                  data: index,
                  feedback: Container(
                    height: 107,
                    width: 107,
                    child: imglist[index],
                  ),
                  child: Container(
                    child: imglist[index],
                  ),
                );
              },);
            },gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,mainAxisSpacing: 3,crossAxisSpacing: 3)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: InkWell(
              onTap: (){
                setState(() {
                  imglist.shuffle();
                });
              },
              child: Container(
                height: 50,
                width: 150,
                color: Colors.black,
                alignment: Alignment.center,
                child: Text("Refresh",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }


}
