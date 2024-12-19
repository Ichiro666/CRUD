import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'playlist_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF1DB954), // Spotify Green
          secondary: Colors.white,
          background: Color(0xFF121212), // Spotify Dark
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          color: Color(0xFF121212),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> tracks = [];
  List<Map<String, dynamic>> playlists = [];
  String accessToken = '';
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _getAccessToken();
  }

  Future<void> _getAccessToken() async {
    final clientId = '50a9f3a3bc17484cbee69dd9d077fc77';
    final clientSecret = '0d2aa783b8db4cc48722a124e1756be7';

    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          accessToken = data['access_token'];
        });
        await _fetchNewReleases();
      } else {
        print('Error getting access token: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception during authentication: $e');
    }
  }

  Future<void> _fetchNewReleases() async {
    if (accessToken.isEmpty) {
      print('No access token available');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/browse/new-releases?limit=20'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tracks = data['albums']['items'];
          isLoading = false;
        });
      } else {
        print('Error fetching tracks: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Exception fetching tracks: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _searchTracks(String query) async {
    if (accessToken.isEmpty || query.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/search?q=$query&type=track&limit=20'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data['tracks']['items'];
          isLoading = false;
          isSearching = true;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Playlist Name'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPlaylist = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': nameController.text,
                'description': descController.text,
                'tracks': [],
              };
              setState(() {
                playlists.add(newPlaylist);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Playlist created!')),
              );
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistsScreen(playlists: playlists),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text('Spotify Music',
            style: TextStyle(color: AppColors.spotifyWhite)),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_play, color: AppColors.spotifyWhite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistManager(
                  playlists: playlists,
                  onPlaylistCreate: (playlist) {
                    setState(() => playlists.add(playlist));
                  },
                  onPlaylistDelete: (id) {
                    setState(() {
                      playlists.removeWhere((p) => p['id'] == id);
                    });
                  },
                  onPlaylistUpdate: (id, name, desc) {
                    setState(() {
                      final playlist =
                          playlists.firstWhere((p) => p['id'] == id);
                      playlist['name'] = name;
                      playlist['description'] = desc;
                      // Image URL will be updated directly in the playlist object
                    });
                  },
                ),
              ),
            ).then((_) => setState(() {})), // Add refresh after returning
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: AppColors.spotifyWhite),
              decoration: InputDecoration(
                hintText: 'Search for tracks...',
                hintStyle:
                    TextStyle(color: AppColors.spotifyWhite.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: AppColors.spotifyWhite),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.spotifyWhite),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            isSearching = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.spotifyDarkGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchTracks(value);
                } else {
                  setState(() {
                    isSearching = false;
                  });
                }
              },
            ),
          ),
          // Results
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount:
                        isSearching ? searchResults.length : tracks.length,
                    itemBuilder: (context, index) {
                      final track =
                          isSearching ? searchResults[index] : tracks[index];
                      return Card(
                        color: AppColors.spotifyDarkGrey,
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              track['images']?[0]?['url'] ??
                                  track['album']?['images']?[0]?['url'] ??
                                  '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.music_note,
                                      color: AppColors.spotifyGreen),
                            ),
                          ),
                          title: Text(
                            track['name'] ?? '',
                            style: TextStyle(color: AppColors.spotifyWhite),
                          ),
                          subtitle: Text(
                            track['artists']?[0]?['name'] ?? '',
                            style: TextStyle(
                                color: AppColors.spotifyWhite.withOpacity(0.7)),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.playlist_add,
                                color: AppColors.spotifyGreen),
                            onPressed: () => _showAddToPlaylistDialog(track),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(dynamic track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.spotifyDarkGrey,
        title: Text('Add to Playlist',
            style: TextStyle(color: AppColors.spotifyWhite)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                title: Text(playlist['name'],
                    style: TextStyle(color: AppColors.spotifyWhite)),
                onTap: () {
                  setState(() {
                    // Add setState here
                    playlist['tracks'].add(track);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to ${playlist['name']}'),
                      backgroundColor: AppColors.spotifyGreen,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    ).then((_) => setState(() {})); // Add refresh after dialog closes
  }
}

class PlaylistsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> playlists;

  PlaylistsScreen({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Playlists')),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return ListTile(
            title: Text(playlist['name']),
            subtitle: Text('${playlist['tracks'].length} tracks'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PlaylistDetailScreen(playlist: playlist),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  final Map<String, dynamic> playlist;

  PlaylistDetailScreen({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playlist['name'])),
      body: ListView.builder(
        itemCount: playlist['tracks'].length,
        itemBuilder: (context, index) {
          final track = playlist['tracks'][index];
          return ListTile(
            leading: Image.network(track['images'][0]['url']),
            title: Text(track['name']),
            subtitle: Text(track['artists'][0]['name']),
          );
        },
      ),
    );
  }
}
