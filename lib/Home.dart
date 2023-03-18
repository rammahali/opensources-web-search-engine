import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_search/Results.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool autoSuggest = false;
  List suggestions = [];
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {

          setState(() {
            autoSuggest = false;
          });
        },
        child: Container(
          height:screenHeight, width: screenWidth,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:  AssetImage("assets/images/background.jpg" ), fit: BoxFit.cover
            )
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [

              Row(
                children: [
                   Image.asset('assets/images/logo-white.png' , height: 160,),
                ],
              ),
              SizedBox(height: 100,),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: screenWidth <= 745 ?   30  : screenWidth/3.5),
                child: Container(
                  alignment: Alignment.center,  padding: EdgeInsets.symmetric(horizontal:  30),
                  height: 70  , width:  screenWidth /2, decoration:
                BoxDecoration (
                   color: Colors.transparent , borderRadius: BorderRadius.circular(20),
                ),
                    child: TextField(
                      onChanged: (value) {
                        if(value != ""){
                           setState(() {
                             autoSuggest = true;
                             // getSearchSuggestions(value);
                             fetchSearchSuggestions(value);
                           });
                        }
                        else {
                          setState(() {
                            autoSuggest = false;
                          });
                        }
                      },
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Results(searchController.text)));
                        },
                      decoration: InputDecoration(
                        suffix: autoSuggest ?
                            InkWell(
                              child: Icon(Icons.close),
                              onTap: () {
                                setState(() {
                                  autoSuggest = false;
                                });
                              },
                            )
                            : SizedBox(),
                        prefixIcon: Icon(Icons.search , color: Colors.deepPurple , size: 30,),
                        filled: true ,
                        fillColor: Colors.white,
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),  borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),  borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),  borderSide: BorderSide(color: Colors. deepPurple)),
                      ),
                    ),
                ),
              ),
             autoSuggest ? Padding(
                padding:  EdgeInsets.symmetric(horizontal: screenWidth <= 745 ?   55  : screenWidth/3.3),
                child: Container(
                    alignment: Alignment.center,  padding: EdgeInsets.symmetric(horizontal:  30 , vertical: 30),
                       width:  screenWidth /2, decoration:
                BoxDecoration (
                  color: Colors.white , borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 15.0,
                          offset: Offset(0.0, 0.75)
                      )
                ],
                ),

                  child: ListView.builder(
                      itemCount: suggestions.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                               suggestionWidget(suggestions[index]['displayText']),
                              ],
                            ),
                            SizedBox(height: 10,),
                          ],
                        );
                      }),
                ),
              ) : SizedBox(),
            ],
          ),

        ),
      ),
    );
  }


  Widget suggestionWidget (String suggestion) {
    return InkWell(
      onTap: () {
        setState(() {
          autoSuggest = false;
          searchController.text = suggestion;
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Results(searchController.text)));
        });
      },
      child: Container(
        child: Row(
          children: [
            Icon(Icons.search , color: Colors.black87,) , SizedBox(width: 40,) ,
            Text(suggestion , style:  GoogleFonts.ubuntu(color: Colors.black87 , fontSize: 17),),
          ],
        ),
      ),
    );
  }


   String endpoint = 'https://api.bing.microsoft.com/v7.0/Suggestions';

     fetchSearchSuggestions(String query) async {
    final uri = Uri.parse('$endpoint?q=$query&mkt=en-US');
    final headers = {
      'Ocp-Apim-Subscription-Key': dotenv.env['API_KEY']!,
    };
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final suggestions = data['suggestionGroups'][0]['searchSuggestions'] as List;

      this.suggestions = suggestions;
     //  return suggestions.map((suggestion) => suggestion['displayText']).toList();
     // print("loading");
      // for(int i = 0 ; i<suggestions.length;i++) {
      //   print(suggestions[i]['displayText']);
      // }
     // print("finished");

    } else {
      throw Exception('Failed to fetch search suggestions: ${response.statusCode}');
    }
  }

}
