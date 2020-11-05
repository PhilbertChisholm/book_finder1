import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  MyApp({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyApp> {
String search = "";

  Future<List<Book>> _getBooks() async
  {
    var url = "https://www.googleapis.com/books/v1/volumes?q=${search}";
    final data = await http.get(url);

    if(data.statusCode == 200) {
      var jsonData = json.decode(data.body);
      final jsonList = (jsonData['items']as List);

      return jsonList.map((jsonBook) => Book(
        jsonBook['volumeInfo']['previewLink'],
        jsonBook['volumeInfo']['imageLinks']['smallThumbnail'],
        jsonBook['volumeInfo']['title'],
         jsonBook['volumeInfo']['author'],
        jsonBook['volumeInfo']['publishedDate'],
        jsonBook['volumeInfo']['description'],

      )).toList();
    }
    else
    {
      throw Exception('Error: ${data.statusCode}');

    }
  }


  @override
  Widget build(BuildContext context) {
//_getBooks();
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Stack(
            children: [
              Container(
                alignment:  Alignment.topLeft,
                padding: EdgeInsets.only(right: 2, top: 7),
                child: Row(
                  children: [
                    Icon(Icons.book,),
                    Text('Book Finder',),
                  ],
                ),
              ),

              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.only(right: 8, top: 30),
                child: Text('Powered by ', style: TextStyle(fontSize: 11),textAlign: TextAlign.center,),
              ),
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.only(right: 5, top: 45),
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: GradientText('Google books',
                        gradient: LinearGradient(
                          colors: [

                            Colors.blue,Colors.blue,Colors.blue,Colors.blue,Colors.blue,
                            Colors.red,
                            Colors.yellow,Colors.yellow,
                            Colors.blue,Colors.blue,
                            Colors.green,Colors.green,
                            Colors.red,Colors.red,
                          ]
                        )),
                  ),),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.blue,

          ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(35),
                      bottomLeft: Radius.circular(35)),
                  color: Colors.blue),
              child: Column(

                        children: [
                            Container(
                              color: Colors.transparent,
                              padding:const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              child: Container(
                                  padding:EdgeInsets.only(top: 5, bottom: 5),

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Colors.white,
                                ),
                                child: TextField(
                                  onChanged: (String value){
                                    setState(() {
                                      search = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(0), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(0),topLeft: Radius.circular(10))),
                                  hintText: 'title, author',
                                  labelText: 'Search',
                                  icon: IconButton(
                                    iconSize: 50,
                                    alignment: Alignment.centerRight,
                                    icon: Icon(Icons.search),
                                    onPressed: (){
                                      setState(() {

                                      });

                                    },),
                                ),),
                              ),
                            ),
                        ],
                    ),
                  ),

            FutureBuilder(
              future: _getBooks(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.connectionState == ConnectionState.done)
                {
                  if(!snapshot.hasData && search == "")
                    {
                      return Center(child: Text('Type to search for a book'),);
                    }
                  else if(snapshot.hasError)
                    return Center(child: Text('Try  again later'),);
                  else if(!snapshot.hasData && search != "")
                    return Center(child: Text('Network on Available'),);
                  else
                  {
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        child: ListView.builder(itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index){
                            return ListTile(contentPadding: EdgeInsets.only(top: 10),
                              subtitle: Text(snapshot.data[index].title),
                              leading:  CircleAvatar(
                                backgroundImage: NetworkImage(snapshot.data[index].img) ,
                              ),
                              onTap: (){
                              _display(context, snapshot.data[index]);
                              },
                            );
                          },),
                      ),
                    );
                  }
                }

              else if(search !="")
                {
                  return
                Center(
                  child: Container(
                  child:
                  CircularProgressIndicator()),

                );}
              else
                return Container();
              }
            ),
          ],
        ),

      ),
    );
  }
}

class Book {
  final String url;
  final String img;
  final String title;
  final String authors;
  final String published;
  final String description;

  Book(this.url, this.img, this.title, this.authors, this.published, this.description);
}

class GradientText extends StatelessWidget {
  GradientText(
      this.text, {
        @required this.gradient,
      });

  final String text;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: TextStyle(
          // The color must be set to white for this to work
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}

Widget _display(BuildContext context, Book book){
  showDialog<Widget>(context: context,
      builder: (BuildContext context){
    return Align(
      alignment: Alignment.center,
      child:
      SimpleDialog(
        titlePadding: EdgeInsets.only(top: 10, bottom: 10),
        title: Text(book.title.toString(), style: TextStyle(fontSize: 16, decoration: TextDecoration.underline), textAlign: TextAlign.center,),
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child:
              SizedBox(child: Image(image: NetworkImage(book.img),) ,)
          ),
          Padding(
            padding: EdgeInsets.only( left:10.0),
            child: Text("Published: "+book.published.toString(),
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.left,),
          ),
          Padding(
            padding: EdgeInsets.only(left:10.0, right: 10.0),
            child: Text(book.description.toString(),
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.left,),
          ),
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.bottomRight,
            child: RaisedButton(
              color: Colors.blue,
              child: Text('Preview'),
              onPressed:() {
                launchURL(book.url.toString());

              }
            ),
          ),

        ],
      ),
    );
  }
  );
}

launchURL(String url) async {
  if (await canLaunch(url+'&redir_esc=y')) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}