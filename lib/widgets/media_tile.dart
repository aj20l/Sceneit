import 'package:flutter/material.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/utils/Watchlist.dart';
import 'package:sceneit/utils/session.dart';

import '../pages/media_details.dart';

class MediaTile extends StatefulWidget {
  final Media media;
  final String imgBaseUrl;
  final double width;

  const MediaTile({
    super.key,
    required this.media,
    required this.imgBaseUrl,
    required this.width,
  });

  @override
  State<StatefulWidget> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> {
  bool _isWatchlist = false;
  WatchlistModel model = WatchlistModel();

  @override
  void initState() {
    super.initState();
    _loadIsWatchlist();
  }

  Future<void> _loadIsWatchlist() async {
    final List<WatchlistItem> items = await model.getWatchlistItem(
      Session.currentUser?.id,
      widget.media.id,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _isWatchlist = items.isNotEmpty;
    });
  }

  void _addToWatchlist() async {
    if (_isWatchlist) {
      final List<WatchlistItem> items;
      items = await model.getWatchlistItem(
        Session.currentUser?.id,
        widget.media.id,
      );
      for (WatchlistItem item in items) {
        model.deleteItem(item.id!);
      }
      setState(() {
        _isWatchlist = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${widget.media.title} to watchlist')),
      );
    } else {
      WatchlistItem item = WatchlistItem(
        userId: Session.currentUser?.id,
        mediaId: widget.media.id,
        title: widget.media.title,
        mediaType: widget.media.mediaType,
        mediaData: widget.media.toMap(),
      );
      await model.insertItem(item);

      setState(() {
        _isWatchlist = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${widget.media.title} to watchlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Stack(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MediaDetailsPage(baseMedia: widget.media),
                        ),
                      ).then((_) {
                        _loadIsWatchlist();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(
                            widget.imgBaseUrl + widget.media.posterPath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _addToWatchlist,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: _isWatchlist
                          ? Icon(Icons.bookmark, color: Colors.white, size: 20)
                          : Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Flexible(
            child: Container(
              alignment: Alignment.center,
              height: 40,
              child: Text(
                widget.media.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
