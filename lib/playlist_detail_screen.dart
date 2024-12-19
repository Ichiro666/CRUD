import 'package:flutter/material.dart';
import 'constants.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final Function(String) onRemoveTrack;

  const PlaylistDetailScreen({
    Key? key,
    required this.playlist,
    required this.onRemoveTrack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tracks = playlist['tracks'] as List;

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text(playlist['name'],
            style: TextStyle(color: AppColors.spotifyWhite)),
      ),
      body: tracks.isEmpty
          ? Center(
              child: Text(
                'No tracks in this playlist',
                style: TextStyle(color: AppColors.spotifyWhite),
              ),
            )
          : ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return Card(
                  color: AppColors.spotifyDarkGrey,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        track['images'][0]['url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      track['name'],
                      style: TextStyle(color: AppColors.spotifyWhite),
                    ),
                    subtitle: Text(
                      track['artists'][0]['name'],
                      style: TextStyle(
                          color: AppColors.spotifyWhite.withOpacity(0.7)),
                    ),
                    trailing: IconButton(
                      icon:
                          Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => onRemoveTrack(track['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
