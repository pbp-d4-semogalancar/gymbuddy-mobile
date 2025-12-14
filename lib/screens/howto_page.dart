import 'package:flutter/material.dart';
import 'package:gymbuddy/models/exercise.dart';
import 'package:gymbuddy/service/howto_service.dart';
import 'package:gymbuddy/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class HowtoPage extends StatefulWidget {
  const HowtoPage({super.key});

  @override
  State<HowtoPage> createState() => _HowtoPageState();
}

class _HowtoPageState extends State<HowtoPage> {
  late Future<List<Exercise>> exercisesFuture;

  String? selectedMuscle;
  String? selectedEquipmentCategory;
  bool showFavoritesOnly = false;

  // favorit PER AKUN dari backend
  Set<int> _favoriteIds = {};
  bool _loadingBookmarks = false;

  List<String> muscleOptions = [];

  final Map<String, String> _muscleAsset = {
    "back": "Back.jpg",
    "calves": "Calves.jpg",
    "chest": "Chest.jpg",
    "forearm": "Forearm.jpg",
    "hips": "Hips.png", // <-- file kamu Hips.png
    "neck": "Neck.jpg",
    "shoulder": "Shoulder.jpg",
    "thighs": "Thighs.jpg",
    "upper arms": "Upperarm.jpg",
  };

  final List<String> equipmentCategoryOptions = const [
    "Barbell",
    "Dumbbell",
    "Cable",
    "Bands",
    "Smith",
    "Sled",
    "Plyometric",
    "Body Weight",
  ];

  final Map<String, String> _equipmentCategoryAsset = {
    "barbell": "Barbell.jpg",
    "dumbbell": "Dumbbell.jpg",
    "cable": "Cable.jpg",
    "bands": "Bands.jpg",
    "smith": "Smith.jpg",
    "sled": "Sled.jpg",
    "plyometric": "Plyometric.jpg",
    "body weight": "Body Weight.png",
  };

  final Map<String, String> _equipmentToCategory = {
    "assisted": "bands",
    "assisted chest dip": "bands",
    "assisted (machine)": "smith",
    "self-assisted": "body weight",
    "suspended": "bands",
    "suspension": "bands",
    "band resistive": "bands",
    "band-assisted": "bands",
    "barbell": "barbell",
    "dumbbell": "dumbbell",
    "cable": "cable",
    "cable standing fly": "cable",
    "cable (pull side)": "cable",
    "lever": "smith",
    "lever (plate loaded)": "smith",
    "lever (selectorized)": "smith",
    "smith": "smith",
    "sled": "sled",
    "sled (plate loaded)": "sled",
    "sled (selectorized)": "sled",
    "plyometric": "plyometric",
    "isometric": "body weight",
    "weighted": "barbell",
    "body weight": "body weight",
  };

  @override
  void initState() {
    super.initState();
    exercisesFuture = HowToService.fetchExercises();
    _loadFilterOptions();

    // load bookmark setelah widget siap (butuh context untuk CookieRequest)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _loadBookmarks(request);
    });
  }

  String _norm(String s) {
    return s
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  Future<void> _loadBookmarks(CookieRequest request) async {
    if (!request.loggedIn) return;
    setState(() => _loadingBookmarks = true);
    try {
      final ids = await HowToService.fetchFavoriteIds(request);
      setState(() => _favoriteIds = ids);
    } catch (_) {
      // biarin aja, jangan crash UI
    } finally {
      if (mounted) setState(() => _loadingBookmarks = false);
    }
  }

  Future<void> _toggleFavorite(CookieRequest request, Exercise ex) async {
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login dulu untuk memakai Favorite.")),
      );
      return;
    }

    final id = ex.id; // pastikan Exercise punya field id
    try {
      final bookmarked = await HowToService.toggleFavorite(request, id);
      setState(() {
        if (bookmarked) {
          _favoriteIds.add(id);
        } else {
          _favoriteIds.remove(id);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal update favorite: $e")),
      );
    }
  }

  Future<void> _loadFilterOptions() async {
    final opts = await HowToService.fetchOptions();

    final mus = (opts["muscles"] ?? [])
        .map((e) => e.toString().replaceAll(RegExp(r'\s+'), ' ').trim())
        .toSet()
        .toList();

    const preferred = [
      "Back",
      "Calves",
      "Chest",
      "Forearm",
      "Hips",
      "Neck",
      "Shoulder",
      "Thighs",
      "Upper Arms",
    ];
    mus.sort((a, b) {
      final ia = preferred.indexOf(a);
      final ib = preferred.indexOf(b);
      final ra = ia == -1 ? 999 : ia;
      final rb = ib == -1 ? 999 : ib;
      return ra.compareTo(rb);
    });

    setState(() => muscleOptions = mus);
  }

  void _applyFilter() {
    setState(() {
      exercisesFuture = HowToService.fetchExercises(muscle: selectedMuscle);
    });
  }



  String? _muscleAssetPath(String apiLabel) {
    final key = _norm(apiLabel);
    final file = _muscleAsset[key];
    return file == null ? null : "lib/Assets/$file";
  }

  String _equipmentCategoryOf(String? rawEquipment) {
    final key = _norm(rawEquipment ?? "");
    if (_equipmentToCategory.containsKey(key)) return _equipmentToCategory[key]!;

    if (key.contains("barbell")) return "barbell";
    if (key.contains("dumbbell")) return "dumbbell";
    if (key.contains("cable")) return "cable";
    if (key.contains("sled")) return "sled";
    if (key.contains("plyometric")) return "plyometric";
    if (key.contains("smith") || key.contains("lever") || key.contains("machine")) return "smith";
    if (key.contains("band") || key.contains("assist") || key.contains("suspens")) return "bands";
    if (key.contains("body")) return "body weight";
    return "body weight";
  }

  String? _equipmentCategoryAssetPath(String categoryLabel) {
    final key = _norm(categoryLabel);
    final file = _equipmentCategoryAsset[key];
    return file == null ? null : "lib/Assets/$file";
  }

  bool _passesEquipmentCategory(Exercise ex) {
    if (selectedEquipmentCategory == null) return true;
    final cat = _equipmentCategoryOf(ex.equipment);
    return cat == _norm(selectedEquipmentCategory!);
  }

  bool _passesFavorites(Exercise ex) {
    if (!showFavoritesOnly) return true;
    return _favoriteIds.contains(ex.id);
  }

  void _showExerciseDetailModal(CookieRequest request, Exercise ex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final isFav = _favoriteIds.contains(ex.id);

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              ex.exerciseName,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            tooltip: "Favorite",
                            onPressed: () async {
                              await _toggleFavorite(request, ex);
                              setLocal(() {}); // refresh icon di modal
                            },
                            icon: Icon(isFav ? Icons.star : Icons.star_border),
                            color: Colors.black,
                          ),
                          IconButton(
                            tooltip: "Tutup",
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.fitness_center, size: 18),
                                const SizedBox(width: 6),
                                Text("Target Muscle: ${ex.mainMuscle}"),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.handyman, size: 18),
                                const SizedBox(width: 6),
                                Text("Equipment: ${ex.equipment ?? "-"}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: const [
                            Icon(Icons.article_outlined, size: 18),
                            SizedBox(width: 6),
                            Text("Instructions:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: SingleChildScrollView(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text((ex.instructions ?? "-").trim(), style: const TextStyle(height: 1.45)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Tutup"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const LeftDrawer(), 
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _headerBanner(),
                    const SizedBox(height: 18),
                    _filterSection(request),
                    const SizedBox(height: 14),
                    _exerciseSection(request),
                    const SizedBox(height: 30),
                    _footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Builder(
      builder: (context) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.25),
              )
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const Spacer(),
              Text(
                "GymBuddy",
                style: TextStyle(
                  color: Colors.grey.shade200,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerBanner() {
    return Stack(
      children: [
        Image.asset("lib/Assets/Background.jpg", width: double.infinity, height: 170, fit: BoxFit.cover),
        Container(width: double.infinity, height: 170, color: Colors.black.withOpacity(0.40)),
        const Positioned(
          left: 18,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🔥 Workout Explorer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Find the perfect exercise for every muscle!", style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterSection(CookieRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Filter by Muscle:"),
        const SizedBox(height: 8),
        _imageFilterRow(
          items: muscleOptions,
          isSelected: (x) => selectedMuscle == x,
          imagePathOf: _muscleAssetPath,
          onTap: (m) => setState(() => selectedMuscle = (selectedMuscle == m ? null : m)),
        ),
        const SizedBox(height: 14),
        _sectionTitle("Filter by Equipment:"),
        const SizedBox(height: 8),
        _imageFilterRow(
          items: equipmentCategoryOptions,
          isSelected: (x) => selectedEquipmentCategory == x,
          imagePathOf: _equipmentCategoryAssetPath,
          onTap: (e) => setState(() => selectedEquipmentCategory = (selectedEquipmentCategory == e ? null : e)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: const Text("Apply Filters"),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => showFavoritesOnly = !showFavoritesOnly),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.black)),
                icon: Icon(showFavoritesOnly ? Icons.star : Icons.star_border),
                label: Text(_loadingBookmarks ? "Loading..." : "Favorites"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imageFilterRow({
    required List<String> items,
    required bool Function(String) isSelected,
    required String? Function(String) imagePathOf,
    required void Function(String) onTap,
  }) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, i) {
          final label = items[i];
          final selected = isSelected(label);
          final path = imagePathOf(label);

          return InkWell(
            onTap: () => onTap(label),
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    height: 52,
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? Colors.black : Colors.transparent, width: 2),
                      boxShadow: [BoxShadow(blurRadius: 8, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.12))],
                    ),
                    child: Center(
                      child: path == null
                          ? const Icon(Icons.image_not_supported, size: 22)
                          : Image.asset(path, fit: BoxFit.contain, height: 40),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }

  Widget _exerciseSection(CookieRequest request) {
    return FutureBuilder<List<Exercise>>(
      future: exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(36), child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Padding(padding: const EdgeInsets.all(16), child: Text("Error: ${snapshot.error}"));
        }

        var items = snapshot.data ?? [];
        items = items.where(_passesEquipmentCategory).where(_passesFavorites).toList();

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final crossAxisCount = w < 520 ? 1 : w < 900 ? 2 : 3;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${items.length} Exercises Found:", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: w < 520 ? 3.2 : 2.3,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) => _exerciseCard(request, items[i]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _exerciseCard(CookieRequest request, Exercise ex) {
    final isFav = _favoriteIds.contains(ex.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 12, offset: const Offset(0, 6), color: Colors.black.withOpacity(0.12))],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ex.exerciseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: "Favorite",
                onPressed: () => _toggleFavorite(request, ex),
                icon: Icon(isFav ? Icons.star : Icons.star_border),
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text("Target Muscle: ${ex.mainMuscle}", style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text("Equipment: ${ex.equipment ?? "-"}", style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              ex.instructions ?? "-",
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.3),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () => _showExerciseDetailModal(request, ex),
              style: TextButton.styleFrom(foregroundColor: Colors.black), // <-- Details hitam
              child: const Text("Details"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("GymBuddy", style: TextStyle(color: Colors.grey.shade200, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Your ultimate workout companion.", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
