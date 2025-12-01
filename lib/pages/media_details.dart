import 'package:flutter/material.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/widgets/media_tile.dart';
import 'package:sceneit/utils/person.dart';

import '../utils/Watchlist.dart';
import '../utils/session.dart';

class MediaDetailsPage extends StatelessWidget {
  final Media baseMedia;
  const MediaDetailsPage({super.key, required this.baseMedia});
  final String _imgBaseUrl = 'https://image.tmdb.org/t/p/w200';

  //populate extra media data, call API
  Future<Media> _fetchData() async {
    final data = await APIHelper.fetchMediaDetails(baseMedia);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SceneIt')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: FutureBuilder<Media>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return Center(child:CircularProgressIndicator());
            }
            else {
              Media media = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(media),
                  Divider(height: 20, indent: 5, endIndent: 5),
                  Text('Overview:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    )
                  ),
                  SizedBox(height: 5.0),
                  Text(media.overview,
                    style: TextStyle(
                      fontSize: 14
                    )
                  ),
                  Divider(height: 20, indent: 5, endIndent: 5),
                  Text('Cast:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )
                  ),
                  SizedBox(height: 5.0),
                  _castList(media.cast ?? []),
                  Divider(height: 20, indent: 5, endIndent: 5),
                  Text('Recommendations:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      )
                  ),
                  SizedBox(height: 5.0),
                  _recommendationList(media.recommendations?? [])
                ]
              );
            }
          })
        )
      )
    );
  }

  Widget _header(Media media) {
    String genres = '';
    for(int i = 0; i < media.genres.length; i++) {
      genres += media.genres[i];
      if (i < media.genres.length - 1) {
        genres += ', ';
      }
    }
    final date = DateTime.parse(media.releaseDate);
    final year = date.year;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 240),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              _imgBaseUrl + media.posterPath,
              fit: BoxFit.cover,
              width: 150,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const CircularProgressIndicator();
              },
            ),
            SizedBox(width:10),
            Flexible(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _boldLabelText(media.title, ' ($year)'),
                  SizedBox(height:10),
                  _boldLabelText('Genres: ', genres),
                  SizedBox(height:10),
                  _boldLabelText('Popularity: ', media.popularity.round().toString()),
                  SizedBox(height:10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rating:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0
                          )
                      ),
                      SizedBox(width: 10),
                      _rating(media.rating),
                    ],
                  ),
                  Spacer(),
                  Bookmark(media: media, size: 30),
                  SizedBox(height: 10)
                ],
              )
            ),
          ]
        )
      )
    );
  }

  Widget _castList(List<Person> cast) {
    //sort cast by order
    cast.sort((p1,p2) => p1.order.compareTo(p2.order));
    cast = cast.take(15).toList();
    return cast.isNotEmpty ? SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, i) {
          final person = cast[i];
          return SizedBox(width: 150, child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_imgBaseUrl + person.profilePath)
                ),
                SizedBox(height:10),
                Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                    ),
                    textAlign: TextAlign.center
                ),
                SizedBox(height:5),
                Text(
                    person.character ?? person.job ?? 'Cast',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14
                    ),
                    textAlign: TextAlign.center
                )
              ]
          ));
        },
      )
    ) : Padding(padding:
    EdgeInsets.only(bottom: 40.0),
        child: Text(
          'Cast not available',
          style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.black87
          ),
        )
    );
  }

  Widget _recommendationList(List<Media> mediaList) {
    mediaList = mediaList.take(10).toList();
    return mediaList.isNotEmpty ? SizedBox(
      height: 275,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaList.length,
        itemBuilder: (context, i) {
          final media = mediaList[i];
          return MediaTile(
            width: 120.0,
            media: media,
            imgBaseUrl: _imgBaseUrl,
          );
        },
      )
    ) : Padding(padding:
      EdgeInsets.only(bottom: 40.0),
        child: Text(
        'No recommendations available',
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: Colors.black87
        ),
      )
    );
  }

  Widget _boldLabelText(String label, String body) {
    return RichText(
      text: TextSpan(
        style: TextStyle(height:1.5),
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: body,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Colors.black,
            ),
          )],
      ),
    );
  }

  Widget _rating(rating) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: rating/10,
            strokeWidth: 5,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.green),
          ),
        ),
        Text(rating.toStringAsFixed(1)),
      ],
    );
  }
}

class Bookmark extends StatefulWidget {
  final Media media;
  final double? size;
  const Bookmark({super.key, required this.media, this.size});
  @override
  State<StatefulWidget> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
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
        widget.media.id
    );
    if(!mounted) {
      return;
    }
    setState(() {
      _isWatchlist = items.isNotEmpty;
    });
  }
  
  void _addToWatchlist() async {
    if(_isWatchlist) {
      final List<WatchlistItem> items;
      items = await model.getWatchlistItem(Session.currentUser?.id, widget.media.id);
      //it should only be 1 item, but in case delete all
      for(WatchlistItem item in items) {
        model.deleteItem(item.id!);
      }
      setState(() {
        _isWatchlist = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(
          'Removed ${widget.media.title} to watchlist')));
    }
    else {
      WatchlistItem item = WatchlistItem(
        userId: Session.currentUser?.id,
        mediaId: widget.media.id,
        title: widget.media.title,
        mediaType: widget.media.mediaType,
        mediaData: widget.media.toMap()
      );
      await model.insertItem(item);

      setState(() {
        _isWatchlist = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(
          'Added ${widget.media.title} to watchlist')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _addToWatchlist,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: _isWatchlist ?
        Icon(Icons.bookmark, color: Colors.white, size: widget.size ?? 20) :
        Icon(Icons.bookmark_border, color: Colors.white, size: widget.size ?? 20)
      ),
    );
  }
}// force
