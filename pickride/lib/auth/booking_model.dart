

// class DriverDashboard extends StatefulWidget {
//   const DriverDashboard({super.key});

//   @override
//   _DriverDashboardState createState() => _DriverDashboardState();
// }

// class _DriverDashboardState extends State<DriverDashboard> {
//   final NotificationService _notificationService = NotificationService();
//   List<Map<String, dynamic>> _notifications = [];
//   bool _hasUnreadNotifications = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   Future<void> _loadNotifications() async {
//     final notifications = await _notificationService.getDriverNotifications();
//     setState(() {
//       _notifications = notifications;
//       _hasUnreadNotifications = notifications.any((n) => !(n['is_read'] as bool));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         drawer: DriverDrawer(),
//         appBar: AppBar(
//           backgroundColor: Colors.green.shade300,
//           actions: [
//             Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.notifications),
//                   onPressed: () => _showNotifications(context),
//                 ),
//                 if (_hasUnreadNotifications)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 12,
//                         minHeight: 12,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//         body: DriverDashboardContent(),
//       ),
//     );
//   }

//   void _showNotifications(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Notifications'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: _notifications.length,
//             itemBuilder: (context, index) {
//               final notification = _notifications[index];
//               return ListTile(
//                 title: Text(notification['message']),
//                 subtitle: Text(DateTime.parse(notification['created_at'])
//                     .toLocal()
//                     .toString()),
//                 leading: Icon(
//                   Icons.circle,
//                   color: notification['is_read'] ? Colors.grey : Colors.green,
//                   size: 12,
//                 ),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }