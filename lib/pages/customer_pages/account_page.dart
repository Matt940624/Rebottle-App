import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rebottle/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

DateTime? lastScanTime;
void timezone() async {
  final now = DateTime.now();

  if (lastScanTime != null && now.difference(lastScanTime!).inSeconds < 2)
    return;

  lastScanTime = now;

  FirebaseFirestore.instance.collection('orders').add({
    'orderId': '12345',
    'status': 'Completed',
    'loggedAt': FieldValue.serverTimestamp(),
  });
  debugPrint("firestore added");
}

void callback() async {
  try {
    DocumentSnapshot order = await FirebaseFirestore.instance
        .collection('orders')
        .doc('12345')
        .get();

    if (order.exists) {
      var data = order.data() as Map<String, dynamic>?;

      if (data != null) {
        var loggedAt = data['loggedAt']; // Access field safely

        if (loggedAt is Timestamp) {
          DateTime dateTime = loggedAt.toDate();
          debugPrint("Order 12345 Timestamp: $dateTime");
        } else {
          debugPrint("loggedAt is null or not a Timestamp");
        }
      } else {
        debugPrint("Error: Document exists but data is null.");
      }
    } else {
      debugPrint("Order not found.");
    }
  } catch (e) {
    debugPrint("Error fetching order: $e");
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User user;
  bool showHistory = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!; // Fetch user in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            // Profile section
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user.email ?? 'No email',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Buttons section - centered with fixed width
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 250, // Fixed width for buttons
                    child: ElevatedButton(
                      onPressed: () => _showInfoDialog(
                        context,
                        "App Info",
                        "Rebottle App\nVersion: 1.0.0\nDeveloped by Matt Shih and Michael Shih",
                      ),
                      style: _buttonStyle(),
                      child: const Text('App Info',
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250, // Fixed width for buttons
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showHistory = !showHistory; // Toggle the history visibility
                        });
                      },
                      style: _buttonStyle(),
                      child: Text(
                        showHistory ? 'Hide History' : 'Show History',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // History section
            if (showHistory) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bottle Return History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("orders")
                        .orderBy('loggedAt', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final orderHistory = snapshot.data!.docs;
                      
                      if (orderHistory.isEmpty) {
                        return Center(
                          child: Text(
                            'No history found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: orderHistory.length,
                        itemBuilder: (context, index) {
                          final order = orderHistory[index];
                          final timestamp = order['loggedAt'] is Timestamp
                              ? order['loggedAt'].toDate()
                              : null;
                              
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.recycling,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                timestamp != null
                                    ? DateFormat('MMM d, yyyy').format(timestamp)
                                    : "No Date",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                timestamp != null
                                    ? DateFormat('h:mm a').format(timestamp)
                                    : "",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Text(
                                "Bottle Returned",
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],

            // This Spacer will push the Sign Out button to the bottom
            // but only take up remaining space when history is not shown
            if (!showHistory) 
              const Spacer(),
            
            // Sign Out Button - always at the bottom
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: 250, // Fixed width for buttons
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[200],
        title: Text(title, style: const TextStyle(color: Colors.black)),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}