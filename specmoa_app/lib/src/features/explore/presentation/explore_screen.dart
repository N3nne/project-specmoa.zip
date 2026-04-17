import 'dart:async';

import 'package:flutter/material.dart';
import 'package:specmoa_app/src/features/explore/data/qualification_models.dart';
import 'package:specmoa_app/src/features/explore/data/qualifications_repository.dart';
import 'package:specmoa_app/src/features/explore/presentation/qualification_detail_screen.dart';
import 'package:specmoa_app/src/shared/widgets/gradient_header.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final QualificationsRepository _repository = QualificationsRepository();
  final TextEditingController _searchController = TextEditingController();

  List<QualificationTab> _tabs = const [];
  List<QualificationCardModel> _items = const [];
  bool _isLoading = true;
  String? _selectedTabCode = 'ALL';
  String? _error;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tabs = await _repository.fetchTabs();
      final items = await _repository.fetchQualifications();

      if (!mounted) return;
      setState(() {
        _tabs = tabs;
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '자격증 목록을 불러오지 못했습니다. 백엔드 연결을 확인해주세요.';
      });
    }
  }

  Future<void> _loadQualifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _repository.fetchQualifications(
        query: _searchController.text.trim(),
        qualgbcd: _selectedTabCode,
      );

      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '자격증 목록을 새로 고치지 못했습니다.';
      });
    }
  }

  String _difficultyLabel(String? difficulty) {
    switch (difficulty) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return '미설정';
    }
  }

  Color _parseCardColor(String? color) {
    if (color == null || color.isEmpty) {
      return const Color(0xFFF3F5FF);
    }

    final normalized = color.replaceFirst('#', '');
    if (normalized.length != 6) {
      return const Color(0xFFF3F5FF);
    }

    return Color(int.parse('FF$normalized', radix: 16));
  }

  void _openDetail(QualificationCardModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QualificationDetailScreen(
          qualificationCode: item.code,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GradientHeader(
          title: '자격증 탐색',
          subtitle: '검색과 탭으로 원하는 자격증을 찾아보세요',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadInitialData,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '자격증명, 분야, 키워드 검색',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) {
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(
                      const Duration(milliseconds: 350),
                      _loadQualifications,
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final selected = tab.code == _selectedTabCode;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(tab.label),
                        onSelected: (_) {
                          setState(() {
                            _selectedTabCode = tab.code;
                          });
                          _loadQualifications();
                        },
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemCount: _tabs.length,
                  ),
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text('검색 결과가 없습니다.'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _parseCardColor(item.displayColor),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.workspace_premium),
                            ),
                            const Spacer(),
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B1F3B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _difficultyLabel(item.difficulty),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7A7EA3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.seriesName.isEmpty
                                  ? item.qualificationTypeName
                                  : item.seriesName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4E557A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _openDetail(item),
                                style: FilledButton.styleFrom(
                                  backgroundColor: item.isFeatured
                                      ? const Color(0xFF5B6CFF)
                                      : const Color(0xFF17B890),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('자세히 보기'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
