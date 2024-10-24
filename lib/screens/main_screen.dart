import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _notificationCount = 0;

  final List<Widget> _screens = [
    const Center(child: Text('홈')),
    const Center(child: Text('예측')),
    const Center(child: Text('분석')),
    const Center(child: Text('내정보')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 알림 카운트를 업데이트하는 메서드 추가
  void updateNotificationCount(int count) {
    setState(() {
      _notificationCount = count;
    });
  }

  // 알림을 확인하고 카운트를 0으로 만드는 메서드
  void _checkNotifications() {
    setState(() {
      _notificationCount = 0;
    });
    // 여기에 알림 목록을 보여주는 로직 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.jpg',
            width: 80,
            height: 80,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _checkNotifications,
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  // 설정 화면으로 이동
                  break;
                case 'help':
                  // 도움말 화면으로 이동
                  break;
                case 'about':
                  // 앱 정보 화면으로 이동
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('설정'),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Text('도움말'),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('앱 정보'),
              ),
            ],
          ),
        ],
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        onTap: _onItemTapped,
      ),
    );
  }
}
