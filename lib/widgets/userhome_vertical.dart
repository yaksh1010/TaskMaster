import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class userhome_vertical extends StatelessWidget {
  const userhome_vertical({
    super.key,
    required this.taskItemStream,
  });

  final Stream? taskItemStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: taskItemStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return GestureDetector(
                onTap: () {
                 
                    
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 20.0, bottom: 20),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          //ClipRRect(
                          //   borderRadius: BorderRadius.circular(20),
                          //   child: Image.network(
                          //     ds["Image"],
                          //     height: 100,
                          //     width: 100,
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                          // const SizedBox(width: 10),
                          const SizedBox(height: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ds["Name"],
                                  //style: AppWidget.semiBoldTextFieldStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  ds["Name"],
                                  //style: AppWidget.semiBoldTextFieldStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  ds["Detail"],
                                  //style: AppWidget.LightTextFieldStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "\₹${ds["Price"]}",
                                  //style: AppWidget.semiBoldTextFieldStyle(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
