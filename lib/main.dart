import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// ===========================================================================
// WARNA & STATE GLOBAL
// Ganti kAccent kalau mau tema warna lain (misal Colors.orange, Colors.teal)
// ===========================================================================
const Color kAccent = Color(0xFF3B82F6);
const Color kDarkBg = Color(0xFF0A1220);
const List<Color> kGradient = [Color(0xFF38BDF8), Color(0xFF2563EB)];

/// Daftar judul film yang difavoritkan
final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

/// Mode tema (gelap / terang)
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

void toggleFavorite(BuildContext context, Movie movie) {
  final current = Set<String>.from(favorites.value);
  final added = !current.contains(movie.title);
  if (added) {
    current.add(movie.title);
  } else {
    current.remove(movie.title);
  }
  favorites.value = current;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        content: Text(added
            ? '${movie.title} ditambahkan ke Favorit'
            : '${movie.title} dihapus dari Favorit'),
      ),
    );
}

void openDetail(BuildContext context, Movie movie, String heroTag) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailPage(movie: movie, heroTag: heroTag),
    ),
  );
}

// ===========================================================================
// DATA
// ===========================================================================
class Movie {
  final String title;
  final String year;
  final String genre;
  final String poster;
  final double rating;
  final String description;

  const Movie({
    required this.title,
    required this.year,
    required this.genre,
    required this.poster,
    required this.rating,
    this.description =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
            'eiusmod tempor incididunt ut labore et dolore magna aliqua.',
  });
}

const List<Movie> movies = [
  Movie(
      title: 'Deadpool & Wolverine',
      year: '2024',
      genre: 'Action',
      rating: 7.7,
      poster: 'assets/images/poster1.jpg'),
  Movie(
      title: 'Bad Boys: Ride or Die',
      year: '2024',
      genre: 'Action',
      rating: 6.8,
      poster: 'assets/images/poster2.jpg'),
  Movie(
      title: 'Inside Out 2',
      year: '2024',
      genre: 'Animation',
      rating: 7.6,
      poster: 'assets/images/poster3.jpg'),
  Movie(
      title: 'A Quiet Place: Day One',
      year: '2024',
      genre: 'Horror',
      rating: 6.6,
      poster: 'assets/images/poster4.jpg'),
  Movie(
      title: 'Fallout',
      year: '2024',
      genre: 'Sci-Fi',
      rating: 8.4,
      poster: 'assets/images/poster5.jpg'),
  Movie(
      title: 'Dune: Part Two',
      year: '2024',
      genre: 'Sci-Fi',
      rating: 8.5,
      poster: 'assets/images/poster6.jpg'),
  Movie(
      title: 'Perfect Days',
      year: '2023',
      genre: 'Drama',
      rating: 8.0,
      poster: 'assets/images/poster7.jpg'),
  Movie(
      title: 'Anatomy of a Fall',
      year: '2023',
      genre: 'Drama',
      rating: 7.7,
      poster: 'assets/images/poster8.jpg'),
];

// ===========================================================================
// APP + TEMA
// ===========================================================================
void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Movie App',
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kAccent,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kAccent,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: kDarkBg,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: kDarkBg,
            ),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

// ===========================================================================
// HOME PAGE
// ===========================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _genre = 'All';
  int _carouselIndex = 0;

  List<String> get _genres => ['All', ...{for (final m in movies) m.genre}];

  List<Movie> _filter(List<Movie> list) {
    if (_genre == 'All') return list;
    return list.where((m) => m.genre == _genre).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featured = _filter(movies).take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (rect) =>
              const LinearGradient(colors: kGradient).createShader(rect),
          child: const Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cari film',
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: MovieSearch()),
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: favorites,
            builder: (context, favs, _) {
              return IconButton(
                tooltip: 'Favorit',
                icon: Badge(
                  label: Text('${favs.length}'),
                  isLabelVisible: favs.isNotEmpty,
                  child: const Icon(Icons.favorite_border),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesPage()),
                ),
              );
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeMode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                tooltip: 'Ganti tema',
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeMode.value =
                    isDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // ---------- Filter genre ----------
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final g = _genres[i];
                final selected = g == _genre;
                return ChoiceChip(
                  label: Text(g),
                  selected: selected,
                  selectedColor: kAccent,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() {
                    _genre = g;
                    _carouselIndex = 0;
                  }),
                );
              },
            ),
          ),

          // ---------- Carousel ----------
          if (featured.isNotEmpty) ...[
            CarouselSlider(
              key: ValueKey(_genre),
              options: CarouselOptions(
                height: 280,
                viewportFraction: 0.85,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, _) =>
                    setState(() => _carouselIndex = index),
              ),
              items: featured
                  .map((m) => _CarouselItem(movie: m))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(featured.length, (i) {
                final active = i == _carouselIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? kAccent : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Tidak ada film untuk genre ini')),
            ),

          // ---------- Section ----------
          MovieSection(title: 'Trending', items: _filter(movies)),
          MovieSection(
              title: 'Popular',
              items: _filter(movies.reversed.toList())),
          MovieSection(
              title: 'Top Rated',
              items: _filter([...movies]
                ..sort((a, b) => b.rating.compareTo(a.rating)))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ===========================================================================
// ITEM CAROUSEL
// ===========================================================================
class _CarouselItem extends StatelessWidget {
  final Movie movie;
  const _CarouselItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'carousel-${movie.title}';

    return GestureDetector(
      onTap: () => openDetail(context, movie, heroTag),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              child: PosterImage(path: movie.poster, title: movie.title),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            // tombol favorit di kanan atas
            Positioned(
              top: 8,
              right: 8,
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: favorites,
                builder: (context, favs, _) {
                  final isFav = favs.contains(movie.title);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? kAccent : Colors.white,
                      ),
                      onPressed: () => toggleFavorite(context, movie),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 14,
              right: 60,
              bottom: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(movie.year,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                      const SizedBox(width: 8),
                      Text(movie.genre,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${movie.rating}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
            ),
            // tombol panah bulat
            Positioned(
              right: 14,
              bottom: 14,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: kGradient),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => openDetail(context, movie, heroTag),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SECTION (dipakai ulang: Trending, Popular, Top Rated)
// ===========================================================================
class MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> items;

  const MovieSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryPage(title: title, items: items),
                  ),
                ),
                child: const Text('More', style: TextStyle(color: kAccent)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 100,
                child: PosterCard(movie: items[index], heroPrefix: title),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// KARTU POSTER (bisa diklik, ada rating & penanda favorit)
// ===========================================================================
class PosterCard extends StatelessWidget {
  final Movie movie;
  final String heroPrefix;

  const PosterCard({super.key, required this.movie, required this.heroPrefix});

  @override
  Widget build(BuildContext context) {
    final heroTag = '$heroPrefix-${movie.title}';

    return GestureDetector(
      onTap: () => openDetail(context, movie, heroTag),
      onLongPress: () => toggleFavorite(context, movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              child: PosterImage(path: movie.poster, title: movie.title),
            ),
            // badge rating
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 11, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text('${movie.rating}',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white)),
                  ],
                ),
              ),
            ),
            // penanda favorit
            Positioned(
              top: 4,
              right: 4,
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: favorites,
                builder: (context, favs, _) {
                  if (!favs.contains(movie.title)) {
                    return const SizedBox.shrink();
                  }
                  return const Icon(Icons.favorite, size: 18, color: kAccent);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// HALAMAN "MORE" (grid semua film dalam satu kategori)
// ===========================================================================
class CategoryPage extends StatelessWidget {
  final String title;
  final List<Movie> items;

  const CategoryPage({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: MovieGrid(items: items, heroPrefix: 'grid-$title'),
    );
  }
}

class MovieGrid extends StatelessWidget {
  final List<Movie> items;
  final String heroPrefix;

  const MovieGrid({super.key, required this.items, required this.heroPrefix});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) =>
          PosterCard(movie: items[i], heroPrefix: heroPrefix),
    );
  }
}

// ===========================================================================
// HALAMAN FAVORIT
// ===========================================================================
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: favorites,
        builder: (context, favs, _) {
          final items = movies.where((m) => favs.contains(m.title)).toList();
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada favorit.\nTekan ikon hati di carousel, '
                  'atau tahan lama poster untuk menambahkan.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return MovieGrid(items: items, heroPrefix: 'fav');
        },
      ),
    );
  }
}

// ===========================================================================
// HALAMAN DETAIL
// ===========================================================================
class DetailPage extends StatelessWidget {
  final Movie movie;
  final String heroTag;

  const DetailPage({super.key, required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 380,
                  width: double.infinity,
                  child: Hero(
                    tag: heroTag,
                    child: PosterImage(path: movie.poster, title: movie.title),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        label: Text('${movie.rating}'),
                      ),
                      Chip(label: Text(movie.year)),
                      Chip(label: Text(movie.genre)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(movie.description,
                      style: const TextStyle(fontSize: 14, height: 1.5)),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: favorites,
                    builder: (context, favs, _) {
                      final isFav = favs.contains(movie.title);
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: kAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border),
                          label: Text(isFav
                              ? 'Hapus dari Favorit'
                              : 'Tambah ke Favorit'),
                          onPressed: () => toggleFavorite(context, movie),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// PENCARIAN
// ===========================================================================
class MovieSearch extends SearchDelegate<void> {
  MovieSearch() : super(searchFieldLabel: 'Cari judul film...');

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final q = query.toLowerCase();
    final result =
        movies.where((m) => m.title.toLowerCase().contains(q)).toList();

    if (result.isEmpty) {
      return const Center(child: Text('Film tidak ditemukan'));
    }

    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (context, i) {
        final m = result[i];
        final tag = 'search-${m.title}';
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 44,
              height: 60,
              child: Hero(
                tag: tag,
                child: PosterImage(path: m.poster, title: m.title),
              ),
            ),
          ),
          title: Text(m.title),
          subtitle: Text('${m.genre} • ${m.year} • ★ ${m.rating}'),
          onTap: () => openDetail(context, m, tag),
        );
      },
    );
  }
}

// ===========================================================================
// GAMBAR POSTER
// Kalau file gambar belum ada, tampil kotak ungu berisi judul film.
// ===========================================================================
class PosterImage extends StatelessWidget {
  final String path;
  final String title;

  const PosterImage({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A5F), Color(0xFF0B1626)],
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        );
      },
    );
  }
}