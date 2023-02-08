import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget {
  Home({Key? key, this.data, this.addData}) : super(key: key);

  var data;
  var addData;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var scroll = ScrollController();
  var flag = 0;

  getMore() async {
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    print(result);
    print(result2);
    widget.addData(result2);
  }

  @override
  void initState(){
    super.initState();
    scroll.addListener(() { //성능샹 이슈로 필요없으면 제거하는 코드도 적용해볼것
      if (scroll.position.pixels == scroll.position.maxScrollExtent && flag == 0){
       getMore();
       flag = 1;
      }

    });

  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      itemCount: widget.data.length,
      itemBuilder: (c,i){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.data[i]['image'].runtimeType == String? Image.network(widget.data[i]['image']) : Image.file(widget.data[i]['image'])
            ,
            Text("좋아요 ${widget.data[i]['likes']}", style: TextStyle(
                fontWeight: FontWeight.bold
            )),
            Text(widget.data[i]['user']),
            Text(widget.data[i]['content'])
          ],
        );
      },
    );
  }
}
