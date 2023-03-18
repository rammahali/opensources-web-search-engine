import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_search/Image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:convert';
import 'dart:js' as js;

import 'package:open_search/ImageSearch.dart';
class Results extends StatefulWidget {
  String query;
 Results(this.query);

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  bool loading = false;
  String query = 'SEARCH_QUERY';
  List searchResult = [];
  bool autoSuggest = false;
  List suggestions = [];
  String desc = "";
  String title = "";
  String descShowImage = "";
  bool imageSearch =  false;
  bool descLoading = false;

  List<ImageResult> imageResults = [];
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: GestureDetector(
        onTap: () {
          setState(() {
            autoSuggest = false;
          });
        },
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                GestureDetector(
                  onTap: () {print(screenWidth);},
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    height: screenWidth <=640 ? 200 : 131,
                    width: screenWidth,
                    child: Column(
                      children: [
                        screenWidth <=640 ?  Image.asset('assets/images/logo-black.png', height: 80,) : SizedBox(),
                        screenWidth <=640 ?  SizedBox(height: 10,) : SizedBox(),
                        Row(
                          children: [
                            Row(
                              children: [
                                screenWidth <=640 ? SizedBox() :Image.asset('assets/images/logo-black.png', height: 100,),
                                SizedBox(width: 10,),
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  height: 70,
                                  width:    screenWidth <=640 ? screenWidth/1.05 : screenWidth / 2.5,
                                  decoration:
                                  BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    onChanged: (value) {
                                      if (value != "") {
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
                                      if(imageSearch ==true) {
                                        imageLoad();
                                        autoSuggest = false;
                                      }
                                      else {
                                        load(value);
                                        autoSuggest = false;
                                      }

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
                                      prefixIcon: Icon(
                                        Icons.search, color: Colors.blueAccent,
                                        size: 30,),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: Colors.white60)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: Colors.white60)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(color: Colors.white60)),
                                    ),
                                  ),
                                ),
                              ],
                            ),


                          ],
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: screenWidth <=640 ? 50: 200 ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    imageSearch = false;
                                    load(searchController.text);
                                  });
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.search , color: imageSearch ? Colors.black87 : Colors.blueAccent,), SizedBox(width: 5,), Text("Search" , style: GoogleFonts.ubuntu(color: imageSearch ? Colors.black87 : Colors.blueAccent, fontSize: 13),),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        loading ? SizedBox() : Container(height: 2, width: 80, color: imageSearch ? Colors.white : Colors.blueAccent,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              SizedBox(width: 20,),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    imageSearch = true;
                                    imageLoad();
                                  });
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.image , color: imageSearch ? Colors.blueAccent : Colors.black87,), SizedBox(width: 5,), Text("Images" , style: GoogleFonts.ubuntu(color: imageSearch ? Colors.blueAccent : Colors.black87 , fontSize: 13),),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        loading ? SizedBox() : Container(height: 2, width: 80, color: imageSearch ? Colors.blueAccent : Colors.white,),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
               imageSearch ? SizedBox(height: 0,)  : SizedBox(height: 5,),
                loading ? LinearProgressIndicator(minHeight: 3,
                  color: Colors.blue,
                  backgroundColor: Colors.grey.shade200,) : SizedBox(),
                imageSearch ? SizedBox(height: 0,)  :SizedBox(height: 30,),
                imageSearch ? imageSearchSection() : Stack(
                  children: [
                    ListView.builder(
                      itemCount: searchResult.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  result(searchResult[index]['name'] ,
                                      searchResult[index]['url'] ,
                                      searchResult[index]['description']
                                  ) ,


                                ],
                              ),
                              SizedBox(height: 20,),
                            ],
                          );
                        }),
                    screenWidth < 1426 ? SizedBox() : desc.length<=0 ? SizedBox() : descLoading ? SizedBox() :   Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 40, right: 120),
                          child: Container(
                            width: screenWidth / 3,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 30),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(title, style: GoogleFonts.ubuntu(
                                        color: Colors.black87, fontSize: 23),),
                                    SizedBox(width: 20, ) ,
                                    Container(height:  130, width: 130,
                                        decoration: BoxDecoration(
                                          color: Colors.white ,
                                          borderRadius: BorderRadius.circular(15),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              descShowImage
                                            )
                                          )
                                        ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 30,),
                                Row(
                                  children: [
                                    Flexible(child: SelectableText(desc,
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.black87, fontSize: 15),
                                      maxLines: 7,))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],),
            autoSuggest ? Padding(
              padding: screenWidth <=640 ? EdgeInsets.only(top :160 , left: 50 ): EdgeInsets.only(top :95 , left: 200, right: screenWidth / 2.5),
              child: Container(
                height: 350,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              width: screenWidth <=640 ? screenWidth / 1.2 : screenWidth / 2,
                decoration:
                BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(13),
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
                          suggestionWidget(
                              suggestions[index]['displayText']),
                          SizedBox(height: 10,),
                        ],
                      );
                    }),
              ),
            ) : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget result(siteName, url, desc) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Padding(
      padding: EdgeInsets.only(left: screenWidth / 12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        width: screenWidth >= 850 ? 800 : screenWidth/1.2,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                js.context.callMethod('open', [url]);
              },
              child: Row(children: [
                Flexible(child: Text(siteName,
                  style: GoogleFonts.ubuntu(color: Colors.blue, fontSize: 25,),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,)),
              ],),
            ),
            SizedBox(height: 5,),
            Row(children: [
              Flexible(child: Text(url,
                style: GoogleFonts.ubuntu(color: Colors.green, fontSize: 16,),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,)),
            ],),
            SizedBox(height: 5,),
            Row(children: [
              Flexible(child: Text(desc,
                style: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 15,),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,),),
            ],)
          ],
        ),
      ),
    );
  }


  Widget imageSearchSection() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 15),
      shrinkWrap: true,
      children: [
        SizedBox(height: 30,),
        Wrap(
          spacing: 8.0, // space between adjacent items
          runSpacing: 7, // space between lines
          children: List.generate(
              imageResults.length,
                  (index) => imageWidget(imageResults[index].name ,imageResults[index].thumbnailUrl)
          ),
        ),
      ],
    );
  }

  Widget imageWidget (String title , String imageLink) {
    if(title.length >=20) {
      title = title = title.substring(0, 20);
      title = title+ "...";
    }
    return Column(
      children: [
        Container(
          height: 200 , width: 200,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                  image: NetworkImage(imageLink)
              )
          ),
        ),
        SizedBox(height: 10,),
        Text( title, style: GoogleFonts.ubuntu(color: Colors.black87, fontSize: 12 , ), overflow:  TextOverflow.ellipsis,)
      ],
    );
  }






  Future<List<Map<String, String>>> searchWeb(String query) async {
    var offset = "0";
    final String host = 'https://api.bing.microsoft.com';
    final String path = '/v7.0/search';
    final String queryParams = '?q=' + Uri.encodeQueryComponent(query) +
        '&count=50&offset=$offset&mkt=en-US,ar,tr';
    final String uri = host + path + queryParams;

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        'Ocp-Apim-Subscription-Key': dotenv.env['API_KEY']!,
      },
    );

    final Map<String, dynamic> data = json.decode(response.body);

    final List<dynamic> resultList = data['webPages']['value'];

    final List<Map<String, String>> results = resultList
        .map((result) =>
    {
      'name': result['name'] as String,
      'url': result['url'] as String,
      'description': result['snippet'] as String,
    })
        .toList();



    return results;
  }

  imageLoad () async {
    setState(() {
      loading = true;
    });
    imageResults.clear();
    imageResults =  await ImageSearch.searchImages(searchController.text);

    setState(() {
      loading = false;
    });
  }


  void load(String query) async {
    setState(() {
      loading = true;
      descLoading = true;
    });
    searchResult.clear();
    print("loading ... ");
    searchResult = await searchWeb(query);
    getShortDescription(query);
    setState(() {
      loading = false;
    });
    print("loaded");
  }

  @override
  void initState() {
    searchController.text = widget.query;
    query = widget.query;
     load(query);
    searchWeb("Google");
    super.initState();
  }

  Widget suggestionWidget(String suggestion) {
    return InkWell(
      onTap: () {
        setState(() {
          autoSuggest = false;
          searchController.text = suggestion;


          if(imageSearch) {
             imageLoad();
          }
          else {
            load(searchController.text);
          }
        });
      },
      child: Container(
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.black87,), SizedBox(width: 40,),
            Flexible(
              child: Text(suggestion,
                style: GoogleFonts.ubuntu(color: Colors.black87, fontSize: 17),),
            ),
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

    } else {
      throw Exception(
          'Failed to fetch search suggestions: ${response.statusCode}');
    }
  }


  getShortDescription(String query) async {
    setState(() {
      descLoading = true;
    });
    var url =
    Uri.parse(
        "https://en.wikipedia.org/w/api.php?action=query&origin=*&format=json&generator=search&gsrnamespace=0&gsrlimit=1&prop=extracts&exintro&explaintext&exsentences=2&gsrsearch='$query'");

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Get the first page ID
      var pageId = data['query']['pages'].keys.first;


      var title = data['query']['pages'][pageId]['title'];
      var description = data['query']['pages'][pageId]['extract'];
      this.desc = description;
      this.title = title;
       await ImageSearch.searchWikiImage(title).then((imageResult) {
         this.descShowImage =  imageResult.thumbnailUrl;
       });
      setState(() {});

      print(description);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    setState(() {
      descLoading = false;
    });
  }


}



