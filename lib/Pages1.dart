import 'main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Page pour enregistrer sont score
class Enregistrer extends StatelessWidget {
  // Create a global key that uniquely identifies the Form widget  
  // and allows validation of the form.  
  final _formKey = GlobalKey<FormState>();  
  Enregistrer({Key? key, required this.score, required this.test, required this.scoredef, required this.platform}) : super(key: key);
  var scoredef;
  var platform;
  bool NameTest = false ;
  final score; 
  bool test;
  var name;
  final TextEditingController _nameController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingSize = screenWidth / 6;
    return Scaffold(
      body: Center(
        child: Padding (
        padding: EdgeInsets.symmetric(horizontal: paddingSize),
          child: Material(
            child: Form(
              key: _formKey,  
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'your score = $score',
                    style: const TextStyle(color: Colors.black, 
                    fontFamily: 'Arial',
                    fontSize: 30.0,
                    ),
                  ),
                ),
                const SizedBox(height: 50.0), // espace entre les boutons
                Container(
                  alignment: Alignment.topCenter,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                child: TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black), 
                    decoration: const InputDecoration(  
                      hintText: 'Enter your name',  
                      labelText: 'name',
                      labelStyle: TextStyle(color: Colors.black),  
                    ),  
                    validator: (value) {  
                      if (value=='') {  
                        return 'Please enter a name';  
                      }  
                      return null;  
                    },  
                  ),
                ),
                ),
                  const SizedBox(height: 50.0), // espace entre les boutons
                  Align(
                  alignment: Alignment.center, 
                    child :ElevatedButton(
                      onPressed: () {
                        // It returns true if the form is valid, otherwise returns false  
                        if (_formKey.currentState!.validate()) {  
                          // If the form is valid, display a Snackbar.  
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Processing Data'),
                          ),
                        ); 
                        }  
                        name = _nameController.text;
                        if (name != '') {
                        // Ajouter des données
                        firestore.collection(platform.toString()).add({
                          'name': name,
                          'score': score,
                        });
                        scoredef = false;
                        notseed = false;
                        Navigator.pop(context, MaterialPageRoute(builder: (context) => const MyApp()));
                        }else {
                          NameTest = true;
                        }
                      },
                      child: const Text('send your score (write your name)'),
                    ),
                  ),
                  const SizedBox(height: 50.0), // espace entre les boutons
                  Align(
                  alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, MaterialPageRoute(builder: (context) => const MyApp()));
                      },
                      child: const Text('Go back and not send my score'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// page pour afficher les higt scores
class Voir extends StatelessWidget {
  Voir({super.key, required this.sortedData, required this.platform});
  var platform;
  var sortedData;
  var scores;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(children: <Widget>[
            const Center(
                child: Text(
              'High score',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('score')),
              ],
            rows:  [
              for (var doc in sortedData)
              if (doc != null)
                DataRow(cells: [
                  DataCell(Text(doc['name'].toString())),
                  DataCell(Text(doc['score'].toString())),
                ]),
             ],
            ),
          ]),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Go back!'),
      ),
    );
  }
}