import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './style.dart' as style;
import './home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(ChangeNotifierProvider(
    create: (c) => Store1(),
    child: MaterialApp(
      home : MyApp(),
      theme: style.theme,
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var userImage;
  var data = [];
  var flag = 0;
  Map<String,dynamic> toJson(image) => {
    'id' : data.length,
    'image': image,
    'likes' : 1,
    'date' : 'Apr 16',
    'content' : '테스트 사진 올리기',
    'liked' : false,
    'user' : 'BW'
  };

  saveData() async{
    var storage = await SharedPreferences.getInstance();
    storage.setString('name', ' John' );
  }



  getDate() async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result2 = jsonDecode(result.body);
    setState(() {
      data = result2;
    });
  }

  addData(a){
    setState(() {
      data.insert(0,a);
    });
  }


  @override
  void initState(){
    super.initState();
    getDate();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [Home(data: data, addData: addData),Profile()][tab],


      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async{
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null){
                  setState(() {
                    userImage = File(image.path);
                  });
                }
                Navigator.push(context,
                MaterialPageRoute(builder: (c)
                    => Upload(userImage : userImage,addData : addData, toJson:toJson)
                  )
                );
              },
              icon: Icon(Icons.add_box_outlined),
              iconSize: 30
          ),
        ],
        centerTitle: false,
        title: Text('Instagram')
      ),


      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i){
          print(i);
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined),label: '샵')
        ],
      ),


    );
  }
}


class Upload extends StatelessWidget {
  Upload({Key? key, this.userImage,this.addData,this.toJson}) : super(key: key);

  var addData;
  var userImage;
  var toJson;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이미지업로드화면'),
            Image.file(userImage),
            IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close)
            ),
            TextButton(onPressed: (){
              Navigator.pop(context);
              addData(toJson(userImage));
            }, child: Text("확인"))
          ],
        )
    );
  }
}

class Store1 extends ChangeNotifier{
  var profileImage = [];

  getData() async {
    var result = await http.get(
        Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    print(profileImage);
    notifyListeners();
  }

  var name = 'john kim';
  var follower  = 0;
  var isFollower = 0;
  changeName() {
    if (isFollower == 0){
      follower+=1;
      isFollower = 1;
    }
    else{
      follower-=1;
      isFollower = 0;
    }
    notifyListeners();
  }
}

class UserDetail extends StatelessWidget {
  const UserDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
        ),
        Text(context.watch<Store1>().follower.toString()),
        ElevatedButton(onPressed: (){
          context.read<Store1>().changeName();
        }, child: Text('버튼')),
        ElevatedButton(onPressed: (){
          context.read<Store1>().getData();
        }, child: Text('사진가져오기'))
      ],
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: UserDetail(),
        ),
        SliverGrid(
            delegate: SliverChildBuilderDelegate(
                    (c,i)=> Container(
    alignment: Alignment.center,
    child:
        Image.network(context.watch<Store1>().profileImage[i])
    ),
            childCount: context.watch<Store1>().profileImage.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3)
        )
      ],
    );
  }
}
