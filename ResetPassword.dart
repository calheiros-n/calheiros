class RedefinirSenha extends StatefulWidget {
  RedefinirSenha({super.key});

  @override
  _RedefinirSenhaState createState() => _RedefinirSenhaState();
}

class _RedefinirSenhaState extends State<RedefinirSenha> {
  final TextEditingController _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isFormValid() {
    return _emailController.text.isNotEmpty;
  }

    void sendPasswordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      showSnackbar("E-mail de redefinição enviado com sucesso!", Colors.green);
    } catch (e) {
      showSnackbar("Erro ao enviar e-mail de redefinição: ${e.toString()}", Colors.red);
    }
  }

  

  void showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(238, 7, 27, 41),
        body: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(),
                ),
              ),
            const SizedBox(
              height: 60,
            ),
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: DCColors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        width: 700,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextInputWidget(
                                  title: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailController,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: InkWell(
                                    onTap: isFormValid() ? sendPasswordResetEmail : null,
                                    child: Container(
                                      width: 784,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        color: isFormValid()
                                            ? DCColors.iron100
                                            : Colors.grey,
                                      ),
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        "Enviar e-mail",
                                        overflow: TextOverflow.ellipsis,
                                        style: DCTheme.headLine.copyWith(
                                            color: DCColors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Text(
                                  "Fazer Login",
                                  style: DCTheme.h2.copyWith(
                                    color: DCColors.iron100,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
