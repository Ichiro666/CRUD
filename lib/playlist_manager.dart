import 'package:flutter/material.dart';

import 'constants.dart';
import 'playlist_detail_screen.dart';

class PlaylistManager extends StatefulWidget {
  final List<Map<String, dynamic>> playlists;
  final Function(Map<String, dynamic>) onPlaylistCreate;
  final Function(String) onPlaylistDelete;
  final Function(String, String, String) onPlaylistUpdate;

  PlaylistManager({
    required this.playlists,
    required this.onPlaylistCreate,
    required this.onPlaylistDelete,
    required this.onPlaylistUpdate,
  });

  @override
  _PlaylistManagerState createState() => _PlaylistManagerState();
}

class _PlaylistManagerState extends State<PlaylistManager> {
  void _refreshState() {
    setState(() {});
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String imageUrl = ''; // Default empty image URL

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text('Create Playlist',
            style: TextStyle(color: AppColors.spotifyWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Preview
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.spotifyLightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl.isEmpty
                  ? Icon(Icons.music_note,
                      color: AppColors.spotifyGreen, size: 40)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
            ),
            SizedBox(height: 16),
            // Image URL Field
            TextField(
              style: TextStyle(color: AppColors.spotifyWhite),
              decoration: InputDecoration(
                labelText: 'Image URL (optional)',
                labelStyle: TextStyle(color: AppColors.spotifyWhite),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.spotifyGreen),
                ),
              ),
              onChanged: (value) => imageUrl = value,
            ),
            TextField(
              controller: nameController,
              style: TextStyle(color: AppColors.spotifyWhite),
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                labelStyle: TextStyle(color: AppColors.spotifyWhite),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.spotifyGreen),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descController,
              style: TextStyle(color: AppColors.spotifyWhite),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: AppColors.spotifyWhite),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.spotifyGreen),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child:
                Text('Cancel', style: TextStyle(color: AppColors.spotifyWhite)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: Text('Create'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                widget.onPlaylistCreate({
                  'id': DateTime.now().toString(),
                  'name': nameController.text,
                  'description': descController.text,
                  'imageUrl': imageUrl,
                  'tracks': [],
                });
                Navigator.pop(context);
                _refreshState();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text('My Playlists',
            style: TextStyle(color: AppColors.spotifyWhite)),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.spotifyGreen,
        child: Icon(Icons.add),
        onPressed: _showCreatePlaylistDialog,
      ),
      body: widget.playlists.isEmpty
          ? Center(
              child: Text(
                'No playlists yet.\nTap + to create one!',
                style: TextStyle(color: AppColors.spotifyWhite),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: widget.playlists.length,
              itemBuilder: (context, index) {
                final playlist = widget.playlists[index];
                return Card(
                  color: AppColors.spotifyDarkGrey,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.spotifyLightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: playlist['imageUrl']?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                playlist['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.music_note,
                                        color: AppColors.spotifyGreen),
                              ),
                            )
                          : Icon(Icons.music_note,
                              color: AppColors.spotifyGreen),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistDetailScreen(
                            playlist: playlist,
                            onRemoveTrack: (trackId) {
                              setState(() {
                                playlist['tracks'].removeWhere(
                                    (track) => track['id'] == trackId);
                                _refreshState();
                              });
                            },
                          ),
                        ),
                      ).then((_) => _refreshState());
                    },
                    title: Text(
                      playlist['name'],
                      style: TextStyle(color: AppColors.spotifyWhite),
                    ),
                    subtitle: Text(
                      '${playlist['tracks']?.length ?? 0} tracks',
                      style: TextStyle(
                          color: AppColors.spotifyWhite.withOpacity(0.7)),
                    ),
                    trailing: PopupMenuButton(
                      color: AppColors.spotifyDarkGrey,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text('Edit',
                              style: TextStyle(color: AppColors.spotifyWhite)),
                          value: 'edit',
                        ),
                        PopupMenuItem(
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          value: 'delete',
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmationDialog(
                              context, playlist, index);
                        } else if (value == 'edit') {
                          // Show edit dialog
                          _showEditDialog(playlist);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, Map<String, dynamic> playlist, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.spotifyDarkGrey,
          title: Text(
            'Delete Playlist',
            style: TextStyle(color: AppColors.spotifyWhite),
          ),
          content: Text(
            'Are you sure you want to delete "${playlist['name']}"?',
            style: TextStyle(color: AppColors.spotifyWhite.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.spotifyGreen)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.playlists.removeAt(index);
                  widget.onPlaylistDelete(playlist['id']);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> playlist) {
    final nameController = TextEditingController(text: playlist['name']);
    final descController = TextEditingController(text: playlist['description']);
    String imageUrl = playlist['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text('Edit Playlist',
            style: TextStyle(color: AppColors.spotifyWhite)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Preview
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.spotifyLightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageUrl.isEmpty
                    ? Icon(Icons.music_note,
                        color: AppColors.spotifyGreen, size: 40)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.music_note,
                              color: AppColors.spotifyGreen,
                              size: 40),
                        ),
                      ),
              ),
              SizedBox(height: 16),
              // Image URL Field
              TextField(
                style: TextStyle(color: AppColors.spotifyWhite),
                controller: TextEditingController(text: imageUrl),
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: TextStyle(color: AppColors.spotifyWhite),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.spotifyGreen),
                  ),
                ),
                onChanged: (value) => imageUrl = value,
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: TextStyle(color: AppColors.spotifyWhite),
                decoration: InputDecoration(
                  labelText: 'Playlist Name',
                  labelStyle: TextStyle(color: AppColors.spotifyWhite),
                ),
              ),
              TextField(
                controller: descController,
                style: TextStyle(color: AppColors.spotifyWhite),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.spotifyWhite),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child:
                Text('Cancel', style: TextStyle(color: AppColors.spotifyWhite)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.spotifyGreen,
            ),
            child: Text('Save'),
            onPressed: () {
              setState(() {
                playlist['name'] = nameController.text;
                playlist['description'] = descController.text;
                playlist['imageUrl'] = imageUrl;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Playlist updated successfully!'),
                  backgroundColor: AppColors.spotifyGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
