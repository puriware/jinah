import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../models/http_exception.dart';
import '../providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sllPrimaryColor,
                  primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          Container(
            height: deviceSize.height,
            width: deviceSize.width,
            padding: EdgeInsets.only(bottom: large),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: deviceSize.width * 0.5,
                  child: Image.asset('assets/images/puriware-long-white.png'),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Flexible(
                  //   child: Container(
                  //     margin: EdgeInsets.only(
                  //       bottom: 20.0,
                  //     ),
                  //     padding: EdgeInsets.symmetric(
                  //       vertical: 8.0,
                  //       horizontal: 94.0,
                  //     ),
                  //     transform: Matrix4.rotationZ(-8 * pi / 180)
                  //       ..translate(-10.0),
                  //     // ..translate(-10.0),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(20),
                  //       color: Colors.deepOrange.shade900,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           blurRadius: 8,
                  //           color: Colors.black26,
                  //           offset: Offset(0, 2),
                  //         )
                  //       ],
                  //     ),
                  //     child: Text(
                  //       'Purishop',
                  //       style: TextStyle(
                  //         color: Theme.of(context).accentTextTheme.headline6!.color,
                  //         fontSize: 50,
                  //         fontFamily: 'Anton',
                  //         fontWeight: FontWeight.normal,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  var _passwordVisible = false;
  AnimationController? _ctrlAnimation;
  Animation<Size>? _heightAnimation;

  @override
  void initState() {
    super.initState();
    _ctrlAnimation = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 700,
      ),
      reverseDuration: Duration(
        milliseconds: 500,
      ),
    );
    _heightAnimation = Tween<Size>(
      begin: Size(double.infinity, 290),
      end: Size(double.infinity, 350),
    ).animate(
      CurvedAnimation(
        parent: _ctrlAnimation!,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_ctrlAnimation != null) _ctrlAnimation!.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error Occurred!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).signIn(
          _authData['email'].toString(),
          _authData['password'].toString(),
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['email'].toString(),
          _authData['password'].toString(),
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Email address is not valid.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not found a user with that email address.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(errorMessage);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _ctrlAnimation!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _ctrlAnimation!.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedBuilder(
        animation: _heightAnimation!,
        builder: (ctx, ch) => Container(
          height: _heightAnimation!.value.height,
          width: deviceSize.width * 0.75,
          padding: EdgeInsets.all(16.0),
          child: ch,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  'Welcome to Jinah',
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(
                  height: large,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'E-Mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                    ),
                    hintText: 'Enter your email address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value.toString();
                  },
                ),
                SizedBox(
                  height: medium,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    hintText: 'Enter password',
                  ),
                  obscureText: !_passwordVisible,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value.toString();
                  },
                ),
                if (_authMode == AuthMode.Signup) ...[
                  SizedBox(
                    height: medium,
                  ),
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      hintText: 'Re-enter password',
                    ),
                    obscureText: !_passwordVisible,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
                SizedBox(
                  height: medium,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      primary: Theme.of(context).primaryColor,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryTextTheme.button!.color,
                      ),
                    ),
                  ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
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
}
