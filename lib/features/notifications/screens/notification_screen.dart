import 'package:flutter/material.dart';
import 'package:mind_print/features/notifications/screens/notification_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

enum _SortBy { newestFirst, olderFirst, readNotification, unreadNotification }

class _NotificationScreenState extends State<NotificationScreen> {
  _SortBy _selectedSort = _SortBy.newestFirst;

  final List<_NotificationItem> _allNotifications = const <_NotificationItem>[
    _NotificationItem(
      title: 'Payment Received',
      message: 'Earn 5% Cashback on Grocery Purchases this Weekend!',
      time: '34 Minutes ago',
      minutesAgo: 34,
      icon: Icons.account_balance_wallet_outlined,
      isRead: false,
    ),
    _NotificationItem(
      title: 'Payment Reminder',
      message: 'Diversify Your Portfolio with Emerging Markets Fund',
      time: '15 Minutes ago',
      minutesAgo: 15,
      icon: Icons.account_balance_wallet_outlined,
      isRead: false,
    ),
    _NotificationItem(
      title: 'Security Alert',
      message: 'Suspicious Login Attempt Detected on Your Account',
      time: '52 Minutes ago',
      minutesAgo: 52,
      icon: Icons.security_outlined,
      isRead: false,
    ),
    _NotificationItem(
      title: 'Loan Reminder',
      message: 'Your Mortgage Payment is Due in 3 Days',
      time: '35 Minutes ago',
      minutesAgo: 35,
      icon: Icons.currency_exchange_outlined,
      isRead: true,
    ),
    _NotificationItem(
      title: 'Budget Advisory',
      message: '80% of Your Monthly Budget Spent - Time for Expense Review!',
      time: '1 Hour ago',
      minutesAgo: 60,
      icon: Icons.savings_outlined,
      isRead: true,
    ),
  ];

  List<_NotificationItem> get _visibleNotifications {
    final List<_NotificationItem> base = List<_NotificationItem>.from(
      _allNotifications,
    );

    switch (_selectedSort) {
      case _SortBy.newestFirst:
        base.sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
        return base;
      case _SortBy.olderFirst:
        base.sort((a, b) => b.minutesAgo.compareTo(a.minutesAgo));
        return base;
      case _SortBy.readNotification:
        return base.where((item) => item.isRead).toList();
      case _SortBy.unreadNotification:
        return base.where((item) => !item.isRead).toList();
    }
  }

  Future<void> _openSortBottomSheet() async {
    _SortBy tempSort = _selectedSort;

    final _SortBy? result = await showModalBottomSheet<_SortBy>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 76,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SortOptionTile(
                    title: 'Newest First',
                    selected: tempSort == _SortBy.newestFirst,
                    onTap:
                        () =>
                            setModalState(() => tempSort = _SortBy.newestFirst),
                  ),
                  _SortOptionTile(
                    title: 'Older First',
                    selected: tempSort == _SortBy.olderFirst,
                    onTap:
                        () =>
                            setModalState(() => tempSort = _SortBy.olderFirst),
                  ),
                  _SortOptionTile(
                    title: 'Read Notification',
                    selected: tempSort == _SortBy.readNotification,
                    onTap:
                        () => setModalState(
                          () => tempSort = _SortBy.readNotification,
                        ),
                  ),
                  _SortOptionTile(
                    title: 'Unread Notification',
                    selected: tempSort == _SortBy.unreadNotification,
                    onTap:
                        () => setModalState(
                          () => tempSort = _SortBy.unreadNotification,
                        ),
                    showBottomBorder: false,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, tempSort),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedSort = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFCFE8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: <Widget>[
                  _circleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Notification',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  _circleButton(icon: Icons.more_vert, onTap: () {}),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: <Widget>[
                          const Text(
                            'Latest notification',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: _openSortBottomSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: const Row(
                                children: <Widget>[
                                  Text(
                                    'Sort By',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: Color(0xFF374151),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        itemCount: _visibleNotifications.length,
                        itemBuilder: (BuildContext context, int index) {
                          final _NotificationItem item =
                              _visibleNotifications[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => NotificationDetailsScreen(
                                        title: item.title,
                                        message: item.message,
                                        time: item.time,
                                      ),
                                ),
                              );
                            },
                            child: _NotificationTile(
                              title: item.title,
                              message: item.message,
                              time: item.time,
                              icon: item.icon,
                              isUnread: !item.isRead,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.isUnread,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 22, color: const Color(0xFF111827)),
              ),
              if (isUnread)
                const Positioned(
                  right: 1,
                  top: 1,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.showBottomBorder = true,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border:
              showBottomBorder
                  ? const Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))
                  : null,
        ),
        child: Row(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
            const Spacer(),
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF9CA3AF),
                  width: 2,
                ),
              ),
              child:
                  selected
                      ? Container(
                        margin: const EdgeInsets.all(3.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.minutesAgo,
    required this.icon,
    required this.isRead,
  });

  final String title;
  final String message;
  final String time;
  final int minutesAgo;
  final IconData icon;
  final bool isRead;
}
