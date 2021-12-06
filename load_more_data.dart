import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shreya_demo/dismisiable/model_class.dart';

class LoadMoreData extends StatefulWidget {
  const LoadMoreData({Key? key}) : super(key: key);

  @override
  _LoadMoreDataState createState() => _LoadMoreDataState();
}

class _LoadMoreDataState extends State<LoadMoreData> {
  //
  ScrollController scrollController = ScrollController();
  Query query = FirebaseFirestore.instance.collection('data').orderBy('name');
  late DocumentSnapshot lastDocument;
  List<ModelClass> userList = [];
  bool isLoading = false;
  //
  @override
  void initState() {
    super.initState();

    //
    loadInitalData();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        //
        loadMoreData();
      }
    });
  }

  //
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  //
  Future<void> loadInitalData() async {
    QuerySnapshot rawData = await query.limit(10).get();
    List<QueryDocumentSnapshot> documentList = rawData.docs;

    documentList.forEach((singleElement) {
      userList.add(ModelClass.fromDocumentSnapshot(singleElement));
    });
    lastDocument = documentList[documentList.length - 1];
    setState(() {
      //
    });
  }

  //
  Future<void> loadMoreData() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot rawData =
        await query.startAfterDocument(lastDocument).limit(10).get();
    List<QueryDocumentSnapshot> documentList = rawData.docs;

    if (documentList.length > 0) {
      documentList.forEach((singleElement) {
        userList.add(ModelClass.fromDocumentSnapshot(singleElement));
      });
      lastDocument = documentList[documentList.length - 1];
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(title: Text('Load More Data')),

      //
      body: userList.length == 0
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                //
                ListView.builder(
                  controller: scrollController,
                  itemCount: userList.length,
                  itemBuilder: (BuildContext context, int index) {
                    ModelClass user = userList[index];

                    return ListTile(
                      //
                      isThreeLine: true,
                      //
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      //
                      title: Text('${user.name}'),

                      subtitle: Text('${user.email}'),
                    );
                  },
                ),

                //
                isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(),
              ],
            ),
    );
  }
}
