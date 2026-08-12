import 'package:flutter/material.dart';
import 'package:renjana/database/db_helper.dart';
import 'package:renjana/models/user_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void _refreshList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Profil Pengguna")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<UserSQLModel>>(
              future: DbHelper().getAllUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  ); // Center
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data pengguna.'),
                  ); // Center
                }

                final daftarPengguna = snapshot.data!;

                return ListView.builder(
                  itemCount: daftarPengguna.length,
                  itemBuilder: (context, index) {
                    final user = daftarPengguna[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ), // CircleAvatar
                        title: Text(user.email),
                        subtitle: Text('Password: ${user.password}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                _showBottomSheet(
                                  context,
                                  daftarPengguna[index],
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                _showBottomSheet(
                                  context,
                                  daftarPengguna[index],
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ), // ListTile
                    ); // Card
                  },
                ); // ListView.builder
              },
            ), // FutureBuilder
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context, UserSQLModel user) {
    final namaController = TextEditingController(text: user.nama);
    final emailController = TextEditingController(text: user.email);
    final noHpController = TextEditingController(text: user.noHp);
    final asalKotaController = TextEditingController(text: user.asalKota);
    final passController = TextEditingController(text: user.password);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ), // RoundedRectangleBorder
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ), // EdgeInsets.only
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kelola Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ), // Text
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ), // InputDecoration
              ), // TextField
              const SizedBox(height: 10),
              TextField(
                controller: passController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ), // InputDecoration
              ), // TextField
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ), // Text
                    onPressed: () async {
                      if (user.id != null) {
                        final updatedUser = UserSQLModel(
                          id: user.id,
                          nama: namaController.text.trim(),
                          email: emailController.text.trim(),
                          noHp: noHpController.text.trim(),
                          asalKota: asalKotaController.text.trim(),
                          password: passController.text,
                        ); // UserModelSQL

                        bool success = await DbHelper().updateUser(updatedUser);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          _refreshList();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil diperbarui'),
                            ), // SnackBar
                          );
                        }
                      }
                    },
                  ), // ElevatedButton.icon
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ), // Text
                    onPressed: () async {
                      if (user.id != null) {
                        await DbHelper().deleteUser(user.id!);
                        if (context.mounted) {
                          Navigator.pop(context);
                          _refreshList();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil dihapus'),
                            ), // SnackBar
                          );
                        }
                      }
                    },
                  ), // ElevatedButton.icon
                ],
              ), // Row
              const SizedBox(height: 20),
            ],
          ), // Column
        ); // Padding
      },
    );
  }
}
