import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:my_pickup/driver.dart';
import 'package:my_pickup/jobdetail.dart';
import 'package:my_pickup/job.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'SlideRightRoute.dart';

double perpage = 1;

class JobList extends StatefulWidget {
  final Driver driver;

  JobList({Key key, this.driver});

  @override
  _JobListState createState() => _JobListState();
}

class _JobListState extends State<JobList> {
   GlobalKey<RefreshIndicatorState> refreshKey;

  List data;

  @override
  Widget build(BuildContext context) {
    
   SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.orange));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomPadding: false,
           
            body: RefreshIndicator(
              key: refreshKey,
              color: Colors.orange,
              onRefresh: () async {
                await refreshList();
              },
              child: ListView.builder(
                  
                  itemCount: data == null ? 1 : data.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        child: Column(
                          children: <Widget>[
                                Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: Text("MyPickup",
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: 300,
                                    height: 140,
                                    child: Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.person,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    widget.driver.name
                                                            .toUpperCase() ??
                                                        "Not registered",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.email,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(widget.driver.email),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.phone,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(widget.driver.phone),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.attach_money,
                                                    ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(widget.driver.credit),
                                                ),
                                              ],
                                            ),
                                            
                                            
                                            
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      
              
                            
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              color: Colors.orange,
                              child: Center(
                                child: Text("Jobs Available Today",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                        ])
                      );
                    }                   
                    if (index == data.length && perpage > 1) {
                      return Container(
                        width: 250,
                        color: Colors.white,
                        child: MaterialButton(
                          child: Text(
                            "Load More",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {},
                        ),
                      );
                    }
                    index -= 1;
                    return Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _onJobDetail(
                            data[index]['job_id'],
                            data[index]['job_cust'],
                            data[index]['job_location'],
                            data[index]['job_destination'],
                            data[index]['job_contact'],
                            data[index]['job_accept'],
                            data[index]['job_driver'],
                            widget.driver.name,
                            widget.driver.credit,
                            
                          ),
                          onLongPress: _onJobDelete,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                      image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                    'assets/images/defaultpic.png'
                                  )))),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                            data[index]['job_cust']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text("Location " + data[index]['job_location']),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text("Destination " + data[index]['job_destination']),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            )));
  }


  Future<String> makeRequest() async {
    String urlLoadJobs = "http://pickupandlaundry.com/my_pickup/chan/php/loadjob.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading Jobs");
    pr.show();
    http.post(urlLoadJobs, body: {
      "email": widget.driver.email ?? "notavailable",
    }).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        data = extractdata["jobs"];
        perpage = (data.length / 10);
        print("data");
        print(data);
        pr.dismiss();
      });
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }

  Future init() async {
    this.makeRequest();
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    this.makeRequest();
    return null;
  }

  void _onJobDetail(
      String job_id,
      String job_cust,
      String job_location,
      String job_destination,
      String job_contact,
      String job_accept,
      String job_driver,
      String name,
      String credit) {
    Job job = new Job(
        job_id: job_id,
        job_cust: job_cust,
        job_location: job_location,
        job_destination: job_destination,
        job_contact: job_contact,
        job_accept: job_accept,
        job_driver: job_driver
       );
    //print(data);
    
    Navigator.push(context, SlideRightRoute(page: JobDetail(job: job, driver: widget.driver)));
  }


  void _onJobDelete() {
    print("Delete");
  }
}

