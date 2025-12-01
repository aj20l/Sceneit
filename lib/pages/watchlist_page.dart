import 'dart:ui';
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
  final String _imgBaseUrl = "https://image.tmdb.org/t/p/w200";

  void _deleteItem(int? id) async {
    if (id != null) {
      await model.deleteItem(id);
      setState(() {});
    }
  }

  Future<void> _selectDateTime(WatchlistItem item) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final DateTime selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    scheduleNotification(item.mediaData['title'], selectedDateTime);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Reminder set for ${item.mediaData['title']} at ${selectedDateTime.toLocal()}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A30FF), Color(0xFF1D1A47)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<WatchlistItem>>(
            future: model.getUserWatchlist(Session.currentUser?.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final data = snapshot.data!;

              if (data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        size: 70,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No items in your Watchlist",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 14,
                ),
                itemCount: data.length,
                itemBuilder: (context, i) {
                  final item = data[i];
                  final media = Media.fromMap(item.mediaData);
                  final active = _selectedItem == item;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedItem = active ? null : item;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(.25),
                        ),
                      ),
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: active
                                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  active ? .18 : .10,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.45),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _imgBaseUrl + media.posterPath,
                                  width: 70,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      media.title,
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: active
                                            ? Colors.white
                                            : Colors.white.withOpacity(.90),
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 8,
                                            color: Colors.white24,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      media.overview,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.3,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 28,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      _deleteItem(item.id);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Removed ${media.title}",
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.alarm,
                                      size: 27,
                                      color: Colors.cyanAccent,
                                    ),
                                    onPressed: () {
                                      _selectDateTime(item);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<void> scheduleNotification(String name, DateTime t) async {
  final now = DateTime.now();
  if (t.isBefore(now)) return;
  Timer(t.difference(now), () {
    NotificationService.showNotification(
      title: name,
      body: "Don't forget to watch 🔔",
    );
  });
}
