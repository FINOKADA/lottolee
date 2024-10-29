import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/colors.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _notificationCount = 0;
  Map<String, dynamic>? _lottoData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLatestLottoData();
  }

  int calculateCurrentRound() {
    final firstDrawDate = DateTime(2002, 12, 7);
    final today = DateTime.now();
    final difference = today.difference(firstDrawDate).inDays;
    return (difference / 7).floor() + 1;
  }

  Future<void> _fetchLatestLottoData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentRound = calculateCurrentRound();
      final response = await http.get(
        Uri.parse(
            'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$currentRound'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['returnValue'] == 'success') {
          setState(() {
            _lottoData = data;
            _isLoading = false;
          });
        } else {
          throw Exception('데이터를 불러올 수 없습니다.');
        }
      } else {
        throw Exception('서버 오류가 발생했습니다.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      });
    }
  }

  Widget _buildLottoBall(int number, {bool isBonus = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size.width * 0.11;

        return Container(
          width: size,
          height: size,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade200,
              ],
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: size * 0.45,
                    fontWeight: FontWeight.bold,
                    color:
                        isBonus ? AppColors.errorColor : AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorColor),
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

    if (_lottoData == null) {
      return const Center(
        child: Text('데이터를 불러올 수 없습니다.'),
      );
    }

    final numberFormat = NumberFormat('#,###');
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final drawDate = DateTime.parse(_lottoData!['drwNoDate']);

    return RefreshIndicator(
      onRefresh: _fetchLatestLottoData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_lottoData!['drwNo']}회 당첨결과',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '추첨일: ${dateFormat.format(drawDate)}',
                        style: const TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLottoBall(_lottoData!['drwtNo1']),
                          _buildLottoBall(_lottoData!['drwtNo2']),
                          _buildLottoBall(_lottoData!['drwtNo3']),
                          _buildLottoBall(_lottoData!['drwtNo4']),
                          _buildLottoBall(_lottoData!['drwtNo5']),
                          _buildLottoBall(_lottoData!['drwtNo6']),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '보너스',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildLottoBall(_lottoData!['bnusNo'], isBonus: true),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '당첨 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        '1등 당첨금',
                        '${numberFormat.format(_lottoData!['firstWinamnt'])}원',
                      ),
                      _buildInfoRow(
                        '1등 당첨자 수',
                        '${_lottoData!['firstPrzwnerCo']}명',
                      ),
                      _buildInfoRow(
                        '총 판매금액',
                        '${numberFormat.format(_lottoData!['totSellamnt'])}원',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildResultSection(),
      const Center(child: Text('예측')),
      const Center(child: Text('분석')),
      const Center(child: Text('내정보')),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => setState(() => _notificationCount = 0),
                color: Colors.black,
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('설정'),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Text('도움말'),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Text('앱 정보'),
              ),
            ],
          ),
        ],
      ),
      body: screens[_selectedIndex],
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
      ),
    );
  }
}
