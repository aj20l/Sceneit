import 'package:flutter/material.dart';
import 'package:sceneit/utils/media.dart';

class MediaTile extends StatelessWidget {
  final Media media;
  final VoidCallback? onTap;
  final String imgBaseUrl;
  final double width;

  const MediaTile({
    super.key,
    required this.media,
    required this.imgBaseUrl,
    required this.width,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
        width:width,
        child: Column(
            children: [
              AspectRatio(
                aspectRatio: 2/3,
                child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                        onTap: onTap,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child:Image.network(
                                  imgBaseUrl + media.posterPath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return const CircularProgressIndicator();
                                  },
                                )
                            )
                          ],
                        )
                    )
                ),
              ),
              SizedBox(height: 4),
              Flexible(
                  child:Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 8.0),
                    height: 40,
                    child: Text(
                      media.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
              )
            ],
          )
      );
  }
}