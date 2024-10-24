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
    const Center(
      child: Text(
        '홈',
        style: TextStyle(color: Color.fromRGBO(109, 56, 233, 1)), // 핑크색 텍스트
      ),
    ),
    const Center(
      child: Text(
        '예측',
        style: TextStyle(color: Color.fromRGBO(109, 56, 233, 1)),
      ),
    ),
    const Center(
      child: Text(
        '분석',
        style: TextStyle(color: Color.fromRGBO(109, 56, 233, 1)),
      ),
    ),
    const Center(
      child: Text(
        '내정보',
        style: TextStyle(color: Color.fromRGBO(109, 56, 233, 1)),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateNotificationCount(int count) {
    setState(() {
      _notificationCount = count;
    });
  }

  void _checkNotifications() {
    setState(() {
      _notificationCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Color.fromRGBO(109, 56, 233, 1)),
                onPressed: _checkNotifications,
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(109, 56, 233, 1),
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
            icon:
                const Icon(Icons.menu, color: Color.fromRGBO(109, 56, 233, 1)),
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
                child: Text('설정',
                    style: TextStyle(color: Color.fromRGBO(109, 56, 233, 1))),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Text('도움말',
                    style: TextStyle(color: Color.fromRGBO(109, 56, 233, 1))),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('앱 정보',
                    style: TextStyle(color: Color.fromRGBO(109, 56, 233, 1))),
              ),
            ],
          ),
        ],
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromRGBO(109, 56, 233, 1), // 핑크색
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
