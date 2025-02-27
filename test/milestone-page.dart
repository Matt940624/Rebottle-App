import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class MilestonePage extends StatefulWidget {
  const MilestonePage({super.key});

  @override
  State<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {
  int currentUses = 0;
  bool isLoading = true;
  late ConfettiController _confettiController;
  final CollectionReference usesCollection = FirebaseFirestore.instance.collection("14 use");

  final List<Map<String, dynamic>> milestones = [
    {'count': 1, 'title': 'First Scan!', 'description': 'You\'ve begun your sustainable journey.'},
    {'count': 3, 'title': 'Getting Started', 'description': 'You\'ve saved 3 bottles so far!'},
    {'count': 5, 'title': 'Eco Enthusiast', 'description': 'You\'re building a great habit.'},
    {'count': 8, 'title': 'Halfway Champion', 'description': 'More than halfway to a free drink!'},
    {'count': 10, 'title': 'Double Digits', 'description': 'Almost there, keep going!'},
    {'count': 14, 'title': 'Rebottle Hero', 'description': 'Congratulations! Claim your free drink!'},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadUserProgress();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    setState(() {
      isLoading = true;
    });

    try {
      // First try to get from Firestore
      final querySnapshot = await usesCollection.orderBy('timestamp', descending: true).limit(1).get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final scanData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if (scanData.containsKey('scancount')) {
          setState(() {
            currentUses = int.parse(scanData['scancount']);
          });
        }
      } else {
        // Fall back to shared preferences if no Firestore data
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          currentUses = prefs.getInt('scan_count') ?? 0;
        });
      }

      // If we've just reached a milestone, show confetti
      if (milestones.any((milestone) => milestone['count'] == currentUses)) {
        _confettiController.play();
      }
    } catch (e) {
      debugPrint('Error loading user progress: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildProgressBar() {
    const totalMilestones = 14;
    final double progressPercentage = currentUses / totalMilestones;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentUses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                '$totalMilestones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 25,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width * progressPercentage - 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue[700]!],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currentUses >= 14 
              ? 'Congratulations! You\'ve earned a free drink!' 
              : '${14 - currentUses} more to go for a free drink!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: currentUses >= 14 ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          final bool isAchieved = currentUses >= milestone['count'];

          return Card(
            elevation: isAchieved ? 4 : 1,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isAchieved ? Colors.green : Colors.grey[300]!,
                width: isAchieved ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAchieved ? Colors.green : Colors.grey[300],
                ),
                child: Center(
                  child: isAchieved
                      ? const Icon(Icons.check, color: Colors.white, size: 30)
                      : Text(
                          milestone['count'].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              title: Text(
                milestone['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isAchieved ? Colors.green : Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  milestone['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isAchieved ? Colors.black87 : Colors.grey[600],
                  ),
                ),
              ),
              trailing: isAchieved
                  ? const Icon(Icons.emoji_events, color: Colors.amber, size: 30)
                  : const Icon(Icons.lock_outline, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Rebottle Journey'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProgress,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink,
                          Colors.orange,
                          Colors.purple
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProgressBar(),
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Text(
                            'Milestone Achievements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          currentUses >= 14
                              ? ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Claim Your Reward'),
                                        content: const Text(
                                            'Show this screen to a staff member to claim your free drink!'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Claim Reward'),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    _buildMilestonesList(),
                  ],
                ),
        ],
      ),
    );
  }
}
