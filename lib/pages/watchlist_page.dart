import 'package:flutter/material.dart';
import 'package:sceneit/utils/Watchlist.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/utils/session.dart';
import 'package:sceneit/utils/notification_service.dart';
import 'dart:async';
class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  WatchlistModel model = WatchlistModel();
  WatchlistItem? _selectedItem;
  final String _imgBaseUrl = 'https://image.tmdb.org/t/p/w200';

  void _deleteItem(int? id) async {
    if(id != null) {
      await model.deleteItem(id);
      setState(() {});
    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WatchlistItem>>(
        future: model.getUserWatchlist(Session.currentUser?.id),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                WatchlistItem item = snapshot.data![i];
                Media media = Media.fromMap(item.mediaData);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if(_selectedItem != item) {
                        _selectedItem = item;
                      }
                      else {
                        _selectedItem = null;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: _selectedItem == item? Colors.black:Colors.white),
                    child: ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 75,
                        child: Image.network(
                          _imgBaseUrl + media.posterPath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                    ),
                      title: Text(media.title),
                      subtitle: Text(media.overview),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                          child:IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () {
                              _deleteItem(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed ${media.title} from watchlist')),
                              );
                            },
                          ),),
                          SizedBox(
                            height: 24,
                            width: 24,
                          child:IconButton(
                            icon: const Icon(Icons.alarm_add),
                            color: Colors.teal,
                            onPressed: () async {
                              // Show  time picker
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (pickedTime == null) return;

                              //  scheduled time
                              final now = DateTime.now();
                              final scheduled = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );


                              await scheduleNotification(media.title, scheduled);


                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(
                                  'Reminder set for ${media.title} at ${pickedTime.format(context)}',
                                )),
                              );
                            },
                          ),),
                        ],
                      ),
                    )
                  )
                );
              }
          );
        }
    );
  }
}
Future<void> scheduleNotification(String mediaTitle, DateTime scheduledTime) async {
  final now = DateTime.now();

  // If the scheduled time is  past, nothing
  if (scheduledTime.isBefore(now)) return;

  // Calculate  wait time
  final duration = scheduledTime.difference(now);

  // Schedule a Timer
  Timer(duration, () {
    NotificationService.showNotification(title: mediaTitle, body: "Don't forget to watch");
  });
}