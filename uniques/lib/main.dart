import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unique sistem',
      home: LoginPage(),
    );
  }
} //clase my app////////////////////

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

//peticion
  Future<void> _login() async {
    try {
      Usuario usuario =
          await getUsuario(_userController.text, _passwordController.text);
      print('Esto es el usuario');
      print(usuario.ap);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventosTabla(usuario: usuario)),
      );
    } catch (e) {
      print(e); //valida usuario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /*SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/fo.png',
              height: 200,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),*/
          const Text(
            "Unique Systems",
            style: TextStyle(
              fontFamily: 'black',
              fontSize: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: TextField(
              controller: _userController,
              obscureText: false,
              decoration: const InputDecoration(
                hintText: 'Usuario',
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.key_outlined),
                labelText: 'Contraseña',
                hintText: 'Contraseña',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _login,
            child: Text('Iniciar sesión'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Recuperar()),
              );
            },
            child: const Text('¿Olvidaste tu contraseña?'),
          ),
        ],
      ),
    );
  }
}

/*class TablaPage extends StatelessWidget {
  final Usuario usuario;

  const TablaPage({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido'),
      ),
      body: Center(
        child: Text('Bienvenido ' + usuario.nombre),
      ),
    );
  }
}*/

Future<Usuario> getUsuario(String user, String pass) async {
  final response = await http.get(Uri.parse(
      'http://technologystaruth5.com.mx/apisCinco/metodos/login.php?username=$user&password=$pass'));

  if (response.statusCode == 200) {
    print('jalo:$user *$pass');
    print(Usuario.fromJson(jsonDecode(response.body)));
    return Usuario.fromJson(jsonDecode(response.body));
  } else {
    print(response.statusCode);
    throw Exception('Error al validar usuario hola');
  } //hace la peticion
}

class Usuario {
  //clase  usuario**********************************************
  var id;
  var nombre;
  var correo;
  var ap;
  var am;
  var password;
  var username;
  var rol;

  Usuario(
      {
      //constructor__________________________________________
      required this.id,
      required this.nombre,
      required this.correo,
      required this.ap,
      required this.am,
      required this.password,
      required this.username,
      required this.rol});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
        id: json['usuario']['id'],
        nombre: json['usuario']['nombre'],
        correo: json['usuario']['correo'],
        ap: json['usuario']['ap'],
        am: json['usuario']['am'],
        password: json['usuario']['password'],
        username: json['usuario']['username'],
        rol: json['usuario'][
            'rol']); //crea json////////////////////////////////////////////////
  }
}

/////////////////////////////////////////PARTE DOS DNADIAAACUCSOIDSJSISF///////////////////77777
//clase EventosTabla**************************************
class EventosTabla extends StatefulWidget {
  final Usuario usuario;

  const EventosTabla({Key? key, required this.usuario}) : super(key: key);

  @override
  _EventosTablaState createState() => _EventosTablaState();
}

class _EventosTablaState extends State<EventosTabla> {
  late Future<Evento?> _futureEvento;

  @override
  void initState() {
    super.initState();
    print(widget.usuario.id);
    _futureEvento = getEvento(widget.usuario.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Evento?>(
      future: _futureEvento,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || snapshot.data == null) {
            return Text('Error al cargar los datos');
          } else {
            final eventos = snapshot.data!.eventos;
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 36, 162, 235),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Hora')),
                    DataColumn(label: Text('Evento')),
                  ],
                  rows: eventos
                      .map((evento) => DataRow(
                            cells: [
                              DataCell(Text(evento.id.toString())),
                              DataCell(Text(evento.hora)),
                              DataCell(Text(evento.evento)),
                            ],
                          ))
                      .toList(),
                ),
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

Future<Evento?> getEvento(int idUsuario) async {
  final response = await http.get(Uri.parse(
      'http://technologystaruth5.com.mx/apisCinco/metodos/readEvento.php?id_usuario=$idUsuario'));
  print(response.statusCode);
  print(response.body);
  print(idUsuario);
  if (response.statusCode == 200) {
    final Map<String, dynamic> eventoJson = jsonDecode(response.body);
    return Evento.fromJson(eventoJson);
  } else {
    throw Exception('Error al cargar los eventos');
  }
}

class Evento {
  final List<EventoItem> eventos;

  Evento({required this.eventos});

  factory Evento.fromJson(Map<String, dynamic> json) {
    final eventO = json['eventO'] as List<dynamic>;
    final eventos = eventO
        .map((evento) => EventoItem.fromJson(evento as Map<String, dynamic>))
        .toList();
    return Evento(eventos: eventos);
  }
}

class EventoItem {
  final int id;
  final int idUsuario;
  final String hora;
  final String evento;

  EventoItem({
    required this.id,
    required this.idUsuario,
    required this.hora,
    required this.evento,
  });

  factory EventoItem.fromJson(Map<String, dynamic> json) {
    return EventoItem(
      id: json['id'] as int,
      idUsuario: json['id_usuario'] as int,
      hora: json['hora'] as String,
      evento: json['evento'] as String,
    );
  }
}

class Recuperar extends StatelessWidget {
  final TextEditingController _recuController = TextEditingController();

  Recuperar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Unique Systems'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                "Recuperar contraseña".toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: TextField(
                  controller: _recuController,
                  obscureText: false,
                  decoration: const InputDecoration(
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Correo electronico',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              ElevatedButton(
                onPressed: () => _recuperarContrasena(_recuController.text),
                child: const Text('Recuperar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*Widget _textFieldEmail() {
  return Container(
    margin: const EdgeInsets.symmetric(
      horizontal: 30.0,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.email_outlined),
        labelText: 'Correo Electrónico',
        hintText: 'example@test.com',
      ),
      onChanged: (value) {},
    ),
  );
}*/

// ignore: non_constant_identifier_names
void _recuperarContrasena(String context) async {
  final response = await http.get(Uri.parse(
      'http://technologystaruth5.com.mx/apisCinco/metodos/recuperar.php?correo=$context'));
  print(response.statusCode);
  print(response);
  if (response.statusCode == 200) {
    final data = response.body;
    print('jalo' + context);
    // ignore: use_build_context_synchronously
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );*/
  } else {
    print('no jalo');
    print(context);
    // ignore: use_build_context_synchronously
    /* ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hubo un error al recuperar la contraseña')),
    );*/
  }
}
