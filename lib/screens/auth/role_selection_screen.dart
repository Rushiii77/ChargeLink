import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Role"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "How would you like to use ChargeLink?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            _buildRoleCard(
              title: "Car Owner",
              subtitle: "Find & Book Chargers",
              icon: Icons.electric_car,
              value: "customer",
            ),

            const SizedBox(height: 20),

            _buildRoleCard(
              title: "Charger Owner",
              subtitle: "List Your Charger & Earn",
              icon: Icons.ev_station,
              value: "owner",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedRole == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Selected Role: $selectedRole",
                            ),
                          ),
                        );

                        // Next:
                        // Navigate to Customer Home
                        // or Owner Dashboard
                      },
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    bool selected = selectedRole == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedRole = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: selected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [

              Icon(
                icon,
                size: 50,
                color: Colors.green,
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(subtitle),
                  ],
                ),
              ),

              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}