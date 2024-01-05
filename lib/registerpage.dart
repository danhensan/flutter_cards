// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registrationFormKey = GlobalKey<FormState>();
  final List<String> genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];
  String? currentGender;
  String? name;
  int? age;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0a6c03),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.center,
              child: Center(
                child: Form(
                  key: _registrationFormKey,
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      children: <Widget>[
                        //deixei ali abaixo o código antigo. Descobri o uso do onChanged
                        // e quis tentar ele no código para ver o funcionamento.
                        // Assim eu consegui retirar o onSave e o .save
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.white)),
                          style: TextStyle(color: Colors.white),
                          onChanged: (val) {
                            setState(() {
                              name = val;
                            });
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Age',
                              labelStyle: TextStyle(color: Colors.white)),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            setState(() {
                              age = int.parse(val);
                            });
                          },
                        ),
                        // TextFormField(
                        //   decoration: InputDecoration(
                        //       labelText: 'Name',
                        //       labelStyle: TextStyle(color: Colors.white)),
                        //   style: TextStyle(color: Colors.white),
                        //   validator: (val) =>
                        //       val!.isEmpty ? 'Please enter a name' : null,
                        //   onSaved: (val) => name = val,
                        // ),
                        // // inicialmente eu só ia colocar a guard clause, para dar um erro caso fosse diferente de um número
                        // // porém, eu lembrei que tinhamos que mudar o teclado. Depois eu pensei em remover a guard clause por isso
                        // // mas lembrei que também daria para copiar e colar kkkkkk
                        // TextFormField(
                        //   decoration: InputDecoration(
                        //       labelText: 'Age',
                        //       labelStyle: TextStyle(color: Colors.white)),
                        //   style: TextStyle(color: Colors.white),
                        //   keyboardType: TextInputType.number,
                        //   inputFormatters: <TextInputFormatter>[
                        //     FilteringTextInputFormatter.digitsOnly
                        //   ],
                        //   validator: (val) {
                        //     if (val!.isEmpty) {
                        //       return 'Please enter an age';
                        //     } else if (int.tryParse(val) == null) {
                        //       return 'Please enter a valid number';
                        //     }
                        //     return null;
                        //   },
                        //   onSaved: (val) => age = int.parse(val!),
                        // ),
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: genders.map((gender) {
                              return RadioListTile<String>(
                                title: Text(
                                  gender,
                                  style: TextStyle(color: Colors.white),
                                ),
                                value: gender,
                                groupValue: currentGender,
                                onChanged: (val) => setState(() {
                                  currentGender = val;
                                }),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: () {
                            if (_registrationFormKey.currentState!.validate()) {
                              // _registrationFormKey.currentState!.save();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return GamePage(
                                        name: name,
                                        age: age,
                                        gender: currentGender);
                                  },
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'Proceed to the game',
                            style: TextStyle(fontSize: 21, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
