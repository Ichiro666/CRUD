import 'package:flutter/material.dart';
import 'constants.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final Function(String)? onRemoveTrack;

  const PlaylistDetailScreen({
    Key? key,
    required this.playlist,
    this.onRemoveTrack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tracks = playlist['tracks'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.spotifyDarkGrey,
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist['name'] ?? 'Playlist',
                  style: TextStyle(color: AppColors.spotifyWhite)),
              background: Container(
                decoration: BoxDecoration(
                  color: AppColors.spotifyLightGrey,
                ),
                child: playlist['imageUrl']?.isNotEmpty == true
                    ? Image.network(
                        playlist['imageUrl']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.music_note,
                            color: AppColors.spotifyGreen,
                            size: 80),
                      )
                    : Center(
                        child: Icon(Icons.music_note,
                            color: AppColors.spotifyGreen, size: 80),
                      ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // Playlist Info Section
              Container(
                padding: EdgeInsets.all(16),
                color: AppColors.spotifyDarkGrey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist['name'] ?? 'Untitled Playlist',
                      style: TextStyle(
                        color: AppColors.spotifyWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (playlist['description']?.isNotEmpty == true) ...[
                      SizedBox(height: 8),
                      Text(
                        playlist['description']!,
                        style: TextStyle(
                          color: AppColors.spotifyWhite.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                    SizedBox(height: 8),
                    Text(
                      '${tracks.length} tracks',
                      style: TextStyle(
                        color: AppColors.spotifyGreen,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 1,
                color: AppColors.spotifyLightGrey,
              ),
              // Tracks List
              ...tracks.map((track) {
                // Safe access to nested properties
                final imageUrl = track['album']?['images']?[0]?['url'] ??
                    track['images']?[0]?['url'] ??
                    '';
                final name = track['name'] ?? 'Unknown Track';
                final artist =
                    track['artists']?[0]?['name'] ?? 'Unknown Artist';
                final id = track['id'] ?? '';

                return Card(
                  color: AppColors.spotifyDarkGrey,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.music_note,
                                      color: AppColors.spotifyGreen),
                            )
                          : Icon(Icons.music_note,
                              color: AppColors.spotifyGreen),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(color: AppColors.spotifyWhite),
                    ),
                    subtitle: Text(
                      artist,
                      style: TextStyle(
                          color: AppColors.spotifyWhite.withOpacity(0.7)),
                    ),
                    trailing: onRemoveTrack != null
                        ? IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () => onRemoveTrack!(id),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ]),
          ),
        ],
      ),
    );
  }
}
