import 'main.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:firedart/firedart.dart' as firedart;
const projectId = 'snake-1fdc7';

// Page pour enregistrer sont score
class Enregistrer extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  Enregistrer({Key? key, required this.score, required this.test, required this.scoredef,required this.scoreCollection}) : super(key: key);
  var scoreCollection;
  var scoredef;
  bool NameTest = false ;
  final score;
  bool test;
  var name;
  final TextEditingController _nameController = TextEditingController();

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
                      onPressed: () async {
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
                        if (name != ''){
                        await scoreCollection.add({
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
  Voir({super.key, required this.users, required this.platform});
  var users;
  var platform;

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
            rows: [
              for (final tuple in users)
                DataRow(cells: [
                  DataCell(Text(tuple.item1)),
                  DataCell(Text(tuple.item2.toString())),
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