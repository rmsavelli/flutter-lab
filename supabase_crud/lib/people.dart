import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'models/person.dart';

final db = DatabaseService();

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});
  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  List<Person> people = [];

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    fetchPeople();
  }

  Future<void> fetchPeople() async {
    final response = await db.fetchPeople();
    setState(() => people = response);
  }

  Future<void> createPerson() async {
    final newPerson = Person(
      id: 0, // supabase will auto-generate
      name: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
    await db.createPerson(newPerson);
    nameController.clear();
    ageController.clear();
    isActive = true;
    fetchPeople();
  }

  Future<void> updatePerson(Person p) async {
    final updated = p.copyWith(
      name: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      isActive: isActive,
    );
    await db.updatePerson(updated);
    fetchPeople();
  }

  Future<void> deletePerson(int id) async {
    await db.deletePerson(id);
    fetchPeople();
  }

  void showEditDialog(Person person) {
    nameController.text = person.name;
    ageController.text = person.age.toString();
    bool localActive = person.isActive;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Editar pessoa'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text("Ativo?"),
                  value: localActive,
                  onChanged: (val) {
                    setStateDialog(() => localActive = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                isActive = localActive;
                updatePerson(person);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD com Supabase')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Idade'), keyboardType: TextInputType.number),
            SwitchListTile(title: const Text("Ativo?"), value: isActive, onChanged: (v) => setState(() => isActive = v)),
            ElevatedButton(onPressed: createPerson, child: const Text("Adicionar")),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: people.length,
                itemBuilder: (_, i) {
                  final p = people[i];
                  return ListTile(
                    title: Text('${p.name} (Idade: ${p.age})'),
                    subtitle: Text('Ativo: ${p.isActive} | Criado: ${p.createdAt}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => showEditDialog(p),
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () => deletePerson(p.id),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}