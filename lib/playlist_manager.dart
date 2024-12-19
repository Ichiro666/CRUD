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
  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text('Create Playlist',
            style: TextStyle(color: AppColors.spotifyWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  'tracks': [],
                });
                Navigator.pop(context);
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
                              });
                            },
                          ),
                        ),
                      );
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
                          widget.onPlaylistDelete(playlist['id']);
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

  void _showEditDialog(Map<String, dynamic> playlist) {
    final nameController = TextEditingController(text: playlist['name']);
    final descController = TextEditingController(text: playlist['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text('Edit Playlist',
            style: TextStyle(color: AppColors.spotifyWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              widget.onPlaylistUpdate(
                playlist['id'],
                nameController.text,
                descController.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
