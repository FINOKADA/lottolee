import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as parser;

// 로또 공 색상 유틸리티
class LottoBallColor {
  static Color getColor(int number) {
    if (number <= 0 || number > 45) {
      return Colors.grey.shade700;
    }
    if (number <= 10) {
      return const Color(0xFFFFB300); // 진한 노랑
    } else if (number <= 20) {
      return const Color(0xFF2196F3); // 진한 파랑
    } else if (number <= 30) {
      return const Color(0xFFE53935); // 진한 빨강
    } else if (number <= 40) {
      return const Color(0xFF757575); // 진한 회색
    } else {
      return const Color(0xFF43A047); // 진한 녹색
    }
  }

  static Color getTextColor(int number) {
    if (number <= 10) {
      return Colors.black87; // 노란 공은 검은 글씨
    } else {
      return Colors.white; // 나머지는 흰 글씨
    }
  }
}

// 로또 당첨 결과 데이터 모델
class LottoResult {
  final int round;
  final DateTime drawDate;
  final List<int> numbers;
  final int bonusNumber;
  final int firstPrizeAmount;
  final int firstWinnerCount;
  final int secondPrizeAmount;
  final int secondWinnerCount;
  final int thirdPrizeAmount;
  final int thirdWinnerCount;
  final int fourthPrizeAmount;
  final int fourthWinnerCount;
  final int fifthPrizeAmount;
  final int fifthWinnerCount;

  const LottoResult({
    required this.round,
    required this.drawDate,
    required this.numbers,
    required this.bonusNumber,
    required this.firstPrizeAmount,
    required this.firstWinnerCount,
    required this.secondPrizeAmount,
    required this.secondWinnerCount,
    required this.thirdPrizeAmount,
    required this.thirdWinnerCount,
    required this.fourthPrizeAmount,
    required this.fourthWinnerCount,
    required this.fifthPrizeAmount,
    required this.fifthWinnerCount,
  });

  factory LottoResult.fromJson(Map<String, dynamic> json) {
    try {
      return LottoResult(
        round: json['drwNo'] ?? 0,
        drawDate: DateTime.parse(
            json['drwNoDate'] ?? DateTime.now().toIso8601String()),
        numbers: [
          json['drwtNo1'] ?? 0,
          json['drwtNo2'] ?? 0,
          json['drwtNo3'] ?? 0,
          json['drwtNo4'] ?? 0,
          json['drwtNo5'] ?? 0,
          json['drwtNo6'] ?? 0,
        ],
        bonusNumber: json['bnusNo'] ?? 0,
        firstPrizeAmount: json['firstWinamnt'] ?? 0,
        firstWinnerCount: json['firstPrzwnerCo'] ?? 0,
        secondPrizeAmount: json['secondWinamnt'] ?? 0,
        secondWinnerCount: json['secondPrzwnerCo'] ?? 0,
        thirdPrizeAmount: json['thirdWinamnt'] ?? 0,
        thirdWinnerCount: json['thirdPrzwnerCo'] ?? 0,
        fourthPrizeAmount: json['fourthWinamnt'] ?? 0,
        fourthWinnerCount: json['fourthPrzwnerCo'] ?? 0,
        fifthPrizeAmount: json['fifthWinamnt'] ?? 0,
        fifthWinnerCount: json['fifthPrzwnerCo'] ?? 0,
      );
    } catch (e) {
      debugPrint('Error parsing LottoResult: $e');
      throw const FormatException('Invalid JSON format for LottoResult');
    }
  }
}

// 로또 뉴스 데이터 모델
class LottoNews {
  final String title;
  final String content;
  final String source;
  final DateTime date;
  final String url;

  const LottoNews({
    required this.title,
    required this.content,
    required this.source,
    required this.date,
    required this.url,
  });

  factory LottoNews.fromError() {
    return LottoNews(
      title: '뉴스를 불러올 수 없습니다.',
      content: '잠시 후 다시 시도해주세요.',
      source: '시스템',
      date: DateTime.now(),
      url: '',
    );
  }
}

// 게시글 데이터 모델
class Post {
  final String content;
  final DateTime timestamp;
  final String nickname;

  const Post({
    required this.content,
    required this.timestamp,
    required this.nickname,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  // 상태 변수들
  int _selectedIndex = 0;
  int _notificationCount = 0;
  LottoResult? _lottoResult;
  bool _isLoading = true;
  String? _errorMessage;
  final List<LottoNews> _newsItems = [];
  bool _isLoadingNews = false;
  bool _isRefreshing = false;

  // 컨트롤러들
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  // 상수들
  static const Duration timeoutDuration = Duration(seconds: 10);
  static const int newsMaxLength = 10;
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  // 초기화 메서드
  Future<void> _initialize() async {
    if (!mounted) return;

    try {
      await Future.wait([
        _fetchLatestLottoData(),
        _fetchNews(),
      ]);
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (!mounted) return;

      setState(() {
        _errorMessage = '초기화 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
        _isLoading = false;
      });
    }
  }

  // 현재 회차 계산 메서드
  int calculateCurrentRound() {
    final firstDrawDate = DateTime(2002, 12, 7);
    final today = DateTime.now();
    final difference = today.difference(firstDrawDate).inDays;
    return (difference / 7).floor() + 1;
  }

  // 날짜 파싱 메서드
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();

    try {
      if (dateStr.contains('분 전') || dateStr.contains('시간 전')) {
        return DateTime.now();
      } else if (dateStr.contains('일 전')) {
        final days = int.tryParse(dateStr.split('일')[0]) ?? 0;
        return DateTime.now().subtract(Duration(days: days));
      } else {
        final parts = dateStr.replaceAll('.', ' ').trim().split(' ');
        if (parts.length >= 3) {
          return DateTime(
            int.tryParse(parts[0]) ?? DateTime.now().year,
            int.tryParse(parts[1]) ?? 1,
            int.tryParse(parts[2]) ?? 1,
          );
        }
      }
    } catch (e) {
      debugPrint('Error parsing date string "$dateStr": $e');
    }
    return DateTime.now();
  }

  // 로또 데이터 가져오기
  Future<void> _fetchLatestLottoData() async {
    if (!mounted || _isRefreshing) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isRefreshing = true;
    });

    try {
      final currentRound = calculateCurrentRound();
      final response = await http.get(
        Uri.parse(
            'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$currentRound'),
        headers: {
          'User-Agent': userAgent,
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
        },
      ).timeout(timeoutDuration);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['returnValue'] == 'success') {
          setState(() {
            _lottoResult = LottoResult.fromJson(data);
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          throw Exception('데이터를 불러올 수 없습니다.');
        }
      } else {
        throw Exception('서버 오류가 발생했습니다. (${response.statusCode})');
      }
    } catch (e) {
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = '서버 응답 시간이 초과되었습니다.';
      } else if (e is FormatException) {
        errorMessage = '데이터 형식이 올바르지 않습니다.';
      } else {
        errorMessage = '데이터를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      }
      _handleError(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _isLoading = false;
        });
      }
    }
  }

  // 뉴스 데이터 가져오기
  Future<void> _fetchNews() async {
    if (!mounted || _isLoadingNews) return;

    setState(() {
      _isLoadingNews = true;
    });

    try {
      final searchTerm =
          Uri.encodeComponent('로또 ${calculateCurrentRound()}회 당첨');
      final response = await http.get(
        Uri.parse(
            'https://search.naver.com/search.naver?where=news&query=$searchTerm'),
        headers: {
          'User-Agent': userAgent,
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      ).timeout(timeoutDuration);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final document = parser.parse(utf8.decode(response.bodyBytes));
        final newsElements = document.querySelectorAll('.news_wrap');
        final newsList = <LottoNews>[];

        for (var element in newsElements.take(newsMaxLength)) {
          try {
            final titleElement = element.querySelector('.news_tit');
            final sourceElement =
                element.querySelector('.info_group a:first-child');
            final dateElement = element.querySelector('.info_group span.info');
            final descriptionElement = element.querySelector('.news_dsc');

            if (titleElement != null && titleElement.text.trim().isNotEmpty) {
              newsList.add(LottoNews(
                title: titleElement.text.trim(),
                content: descriptionElement?.text.trim() ?? '내용이 없습니다.',
                source: sourceElement?.text.trim() ?? '출처 미상',
                date: _parseDate(dateElement?.text.trim()),
                url: titleElement.attributes['href'] ?? '',
              ));
            }
          } catch (e) {
            debugPrint('Error parsing news item: $e');
            continue;
          }
        }

        if (!mounted) return;

        setState(() {
          _newsItems.clear();
          _newsItems.addAll(newsList);
        });
      } else {
        throw Exception('뉴스를 불러올 수 없습니다. (${response.statusCode})');
      }
    } catch (e) {
      _handleNewsError(
        e is TimeoutException ? '서버 응답 시간이 초과되었습니다.' : '뉴스를 불러오는 중 오류가 발생했습니다.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
        });
      }
    }
  }

  // 에러 처리 메서드들
  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  void _handleNewsError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoadingNews = false;
      _newsItems
        ..clear()
        ..add(LottoNews.fromError());
    });
  }

  // 당첨 정보 다이얼로그
  void _showPrizeInfo(LottoResult result) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${result.round}회 당첨 정보',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPrizeRow('1등', result.firstWinnerCount,
                      result.firstPrizeAmount, '6개 번호 일치'),
                  _buildPrizeRow('2등', result.secondWinnerCount,
                      result.secondPrizeAmount, '5개 번호 + 보너스 번호 일치'),
                  _buildPrizeRow('3등', result.thirdWinnerCount,
                      result.thirdPrizeAmount, '5개 번호 일치'),
                  _buildPrizeRow('4등', result.fourthWinnerCount,
                      result.fourthPrizeAmount, '4개 번호 일치'),
                  _buildPrizeRow('5등', result.fifthWinnerCount,
                      result.fifthPrizeAmount, '3개 번호 일치'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 뉴스 상세 다이얼로그
  void _showNewsDetail(LottoNews news) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            news.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppColors.textSecondaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          news.source,
                          style: TextStyle(
                            color: AppColors.primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('yyyy.MM.dd').format(news.date),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimaryColor,
                          height: 1.5,
                        ),
                      ),
                      if (news.url.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // URL 처리 로직 추가 예정
                          },
                          child: const Text(
                            '원문 보기',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 당첨 정보 행 위젯
  Widget _buildPrizeRow(
      String rank, int winners, int amount, String condition) {
    final numberFormat = NumberFormat('#,###');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                rank,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  condition,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '당첨자 수: ${numberFormat.format(winners)}명',
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                '${numberFormat.format(amount)}원',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(height: 12),
        ],
      ),
    );
  }

  // 로또 볼 위젯
  Widget _buildLottoBall(int number, {bool isBonus = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size.width * 0.09; // 크기 줄임

        return Container(
          width: size,
          height: size,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LottoBallColor.getColor(number),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: LottoBallColor.getTextColor(number),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 뉴스 섹션 위젯
  Widget _buildNewsSection() {
    if (_isLoadingNews) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '로또 뉴스',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: _fetchNews,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    '새로고침',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _newsItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final news = _newsItems[index];
              return InkWell(
                onTap: () => _showNewsDetail(news),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            news.source,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy.MM.dd').format(news.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 결과 섹션 위젯
  Widget _buildResultSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.errorColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchLatestLottoData,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLatestLottoData,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          if (_lottoResult != null) ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: InkWell(
                onTap: () => _showPrizeInfo(_lottoResult!),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${_lottoResult!.round}회 당첨결과',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('yyyy년 MM월 dd일')
                            .format(_lottoResult!.drawDate),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ..._lottoResult!.numbers.map(
                            (number) => _buildLottoBall(number),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          _buildLottoBall(_lottoResult!.bonusNumber,
                              isBonus: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          _buildNewsSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => setState(() => _notificationCount = 0),
                color: AppColors.textPrimaryColor,
                iconSize: 22,
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textPrimaryColor,
              size: 22,
            ),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  // 설정 페이지로 이동
                  break;
                case 'help':
                  // 도움말 표시
                  break;
                case 'about':
                  // 앱 정보 표시
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('설정', style: TextStyle(fontSize: 14)),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Text('도움말', style: TextStyle(fontSize: 14)),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Text('앱 정보', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildResultSection(),
          const Center(child: Text('예측')), // 추후 구현
          const Center(child: Text('분석')), // 추후 구현
          const Center(child: Text('내정보')), // 추후 구현
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: '예측',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: '분석',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '내정보',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}
