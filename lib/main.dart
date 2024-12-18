import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';

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
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  bool showResults = false;
  String accessToken = '';
  List<Map<String, dynamic>> favoriteTracks = [];

  @override
  void initState() {
    super.initState();
    _getAccessToken();
    _loadFavoriteTracks();
  }

  Future<void> _getAccessToken() async {
    final clientId = '50a9f3a3bc17484cbee69dd9d077fc77';
    final clientSecret = '0d2aa783b8db4cc48722a124e1756be7';

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
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        accessToken = jsonResponse['access_token'];
      });
    } else {
      // Handle error
      print('Failed to get access token');
    }
  }

  Future<void> _loadFavoriteTracks() async {
    final tracks = await DatabaseHelper.instance.getFavoriteTracks();
    setState(() {
      favoriteTracks = tracks;
    });
  }

  Future<void> searchTracks(String query) async {
    if (accessToken.isEmpty) {
      print('No access token available');
      return;
    }

    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$query&type=track&limit=20'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        searchResults = data['tracks']['items'];
        isLoading = false;
        showResults = true;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to search tracks: ${response.statusCode}');
    }
  }

  void deleteMovie(int index) {
    setState(() {
      searchResults.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Spotify Track Search",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteTracksScreen(
                    favoriteTracks: favoriteTracks,
                    onDelete: (String id) async {
                      await DatabaseHelper.instance.deleteFavoriteTrack(id);
                      _loadFavoriteTracks();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                labelText: "Search for a track",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String query = searchController.text.trim();
                if (query.isNotEmpty) {
                  searchTracks(query);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1DB954),
                foregroundColor: Colors.white,
              ),
              child: Text("Search"),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : showResults
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final track = searchResults[index];
                            return TrackCard(
                              track: track,
                              onDelete: () => deleteMovie(index),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          "Search for a track to see results",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class TrackCard extends StatelessWidget {
  final dynamic track;
  final VoidCallback onDelete;

  const TrackCard({required this.track, required this.onDelete, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: track['album']['images'].isNotEmpty
            ? Image.network(
                track['album']['images'].last['url'],
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              )
            : Icon(Icons.music_note, size: 50, color: Color(0xFF1DB954)),
        title: Text(
          track['name'],
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "${track['artists'][0]['name']}\n${track['album']['name']}",
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () async {
                await DatabaseHelper.instance.saveFavoriteTrack(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to favorites')),
                );
              },
            ),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TrackDetails(track: track, onDelete: onDelete),
            ),
          );
        },
      ),
    );
  }
}

class TrackDetails extends StatelessWidget {
  final dynamic track;
  final VoidCallback onDelete;

  const TrackDetails({required this.track, required this.onDelete, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(track['name'], style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: track['album']['images'].isNotEmpty
                  ? Image.network(
                      track['album']['images'][0]['url'],
                      fit: BoxFit.cover,
                      height: 300,
                    )
                  : Icon(Icons.music_note, size: 100, color: Color(0xFF1DB954)),
            ),
            SizedBox(height: 20),
            Text(
              track['name'],
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Artist: ${track['artists'][0]['name']}",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              "Album: ${track['album']['name']}",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  onDelete();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child:
                    Text("DELETE TRACK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteTracksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteTracks;
  final Function(String) onDelete;

  const FavoriteTracksScreen({
    required this.favoriteTracks,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Tracks', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: favoriteTracks.length,
        itemBuilder: (context, index) {
          final track = favoriteTracks[index];
          return Card(
            color: Colors.grey[900],
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              leading: track['imageUrl'].isNotEmpty
                  ? Image.network(
                      track['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.music_note, color: Color(0xFF1DB954)),
              title: Text(
                track['name'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${track['artist']}\n${track['albumName']}',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(track['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
