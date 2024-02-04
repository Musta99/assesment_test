import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IssueLists extends StatefulWidget {
  const IssueLists({Key? key}) : super(key: key);

  @override
  State<IssueLists> createState() => _IssueListsState();
}

class _IssueListsState extends State<IssueLists> {
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  List<dynamic> data = [];

  Future fetchData() async {
    final String apiUrl = 'https://musta99.github.io/issuelist/issue.json';

    final response = await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode == 200) {
      setState(() {
        _data = jsonDecode(utf8.decode(response.bodyBytes));
        _filteredData = _data;
      });
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  List _searchIssues(String query) {
    if (query.isEmpty) {
      return _data;
    }

    query = query.toLowerCase();

    return _data.where((issue) {
      return (issue["author"]?.toString().toLowerCase() ?? '')
              .contains(query) ||
          (issue["title"]?.toString().toLowerCase() ?? '').contains(query) ||
          (issue["body"]?.toString().toLowerCase() ?? '').contains(query) ||
          ((issue["labels"] as List?)?.contains(query) ?? false) ||
          (issue["date"]?.toString().toLowerCase() ?? '').contains(query);
    }).toList();
  }

  //// Search by labels ////
  List searchByLabel(String label) {
    if (label.isEmpty) {
      return _data;
    }

    label = label.toLowerCase();

    return _data.where((element) {
      return (element["labels"] as List?)
              ?.any((issueLabel) => issueLabel.toLowerCase().contains(label)) ??
          false;
    }).toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData().then((_) {
      data = _filteredData;
      print(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Issues",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Issues list",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredData = searchByLabel(value);
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            _filteredData.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text("No Data to Show"),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _filteredData[index]["title"]
                                              .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          _filteredData[index]["body"]
                                              .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xffd9d8d8),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              _filteredData[index]["labels"]
                                                  .toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff13a4a9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _filteredData[index]["date"]
                                              .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          _filteredData[index]["author"]
                                              .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          );
                        }),
                  ),
            // ElevatedButton(
            //     onPressed: () {
            //       print(_filteredData);
            //     },
            //     child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
