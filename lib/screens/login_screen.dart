import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //Importar el timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  //1.1 Máquina de estados / Solo tenemos un StateMachine
  StateMachineController? _controller;
  //StateMachineInput
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccsess;
  SMITrigger? _trigFail;
  SMINumber? _numLock;

  //Timer para recorrer el recorrido de la mirada
  Timer? _typingDebounce;


  //2.1 Crear variables FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {

    super.initState();

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        if (_isHandsUp != null) {
        _isHandsUp?.change(false);
        //3.3 Mirada neutral
        _numLock?.value = 50;
       }
      }
      
    });

    _passwordFocus.addListener(() {
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });    
  }

  
  
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/Loging-bear-animation.riv',
                    stateMachines: ['Login Machine'],
                    onInit: (artboard){
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );
                      //1.3 Verificar que inicio bien
                      if (_controller == null) return;
                      artboard.addController(_controller!);
                      //1.4 Vincular as variables
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccsess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLock = _controller!.findSMI('numLook');
                    },
                  ),
                ),
        
                //Para separar elementos
                const SizedBox(height: 10),
                //Email
                
                TextField(
                  //2.3Asignar el focus al tect field
                  focusNode: _emailFocus,

                  onChanged: (value){
                    if(_isHandsUp != null){
                      //No tapes los ojos al ver el email
                      //_isHandsUp!.change(false);
                    }
                    //Si isCheckimg es null
                    if (_isChecking == null) return;
                    //Activa modo chismoso
                    _isChecking!.change(true);
                    //3.4 Implementar recorrido de la mirada. Se ajusta limites del 0 al 100. 
                    //80 Medida de Calibración
                    final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                    _numLock?.value = look;

                    //3.5 Debpunce: Si vuelve a teclear, reinicia el contador
                    _typingDebounce?.cancel();
                    //Crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      //Si se cierra la pantalla, se cierra la ejecucion
                      if (!mounted) return;
                      //Mirada neutra
                      _isChecking?.change(false);
                    });


                  },
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
        
                const SizedBox(height: 10),
        
                //Contraseña
                TextField(
                  //2.3Asignar el focus al tect field
                  focusNode: _passwordFocus,
                  obscureText: _isObscure,
                  onChanged: (value){
                    if(_isChecking != null){
                      //No mires mientras escribe la contraseña
                      //isChecking!.change(false);
                    }

                    //Si isHandsUp es null
                    if (_isHandsUp == null) return;
                    //Tapa los ojos
                    _isHandsUp!.change(true);
                  },
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(
                        //If ternario
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    //2.4 Liberar espacio en memoria en los Focuses Node
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
