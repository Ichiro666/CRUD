import 'package:flutter/material.dart';

import 'constants.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playlist;
  final Function(String)? onRemoveTrack;

  const PlaylistDetailScreen({
    Key? key,
    required this.playlist,
    this.onRemoveTrack,
  }) : super(key: key);

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late List tracks;

  @override
  void initState() {
    super.initState();
    // Initialize tracks from playlist
    tracks = widget.playlist['tracks'] as List? ?? [];
  }

  void removeTrack(String id) {
    setState(() {
      tracks.removeWhere((track) => track['id'] == id);
    });
    if (widget.onRemoveTrack != null) {
      widget.onRemoveTrack!(id);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              background: Container(
                decoration: BoxDecoration(
                  color: AppColors.spotifyLightGrey,
                ),
                child: widget.playlist['imageUrl']?.isNotEmpty == true
                    ? Image.network(
                        widget.playlist['imageUrl']!,
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
                      widget.playlist['name'] ?? 'Untitled Playlist',
                      style: TextStyle(
                        color: AppColors.spotifyWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.playlist['description']?.isNotEmpty == true) ...[
                      SizedBox(height: 8),
                      Text(
                        widget.playlist['description']!,
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
                    trailing: IconButton(
                      icon:
                          Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => removeTrack(id),
                    ),
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
