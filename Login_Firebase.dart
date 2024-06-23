class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> loginUser() async {
    isLoading(true);
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        Get.offAll(() => Home());
      }
    } on FirebaseAuthException catch (e) {
      Get.dialog(AlertDialog(
        backgroundColor: DCColors.white,
        title: Center(child: Text('Erro ao efetuar o login')),
        content: Text('O email ou a senha inserida se encontram inválidos.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: DCColors.iron100,
                    borderRadius: BorderRadius.circular(4)),
                child: Center(
                  child: Text('Tentar novamente',
                      style: DCTheme.body2.copyWith(color: DCColors.white)),
                )),
          ),
        ],
      ));
    } finally {
      isLoading(false);
    }
}
}

class Login extends StatelessWidget {
  final LoginController loginController =
      Get.put(LoginController()); // Instancia o controller

  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DCColors.background,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              color: DCColors.iron200,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Image.asset('lib/assets/svg/logo.jpg',),
                ),
              ),
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
                                controller: loginController.emailController,
                              ),
                              TextInputWidget(
                                title: 'Senha',
                                keyboardType: TextInputType.text,
                                controller: loginController.passwordController,
                                isPassword: true,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: () {
                                    loginController.loginUser();
                                  },
                                  child: Obx(() => Container(
                                        width: 784,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: loginController.isLoading.value
                                              ? DCColors.success100
                                              : DCColors.iron200,
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          loginController.isLoading.value
                                              ? 'Carregando...'
                                              : 'Entrar',
                                          overflow: TextOverflow.ellipsis,
                                          style: DCTheme.headLine
                                              .copyWith(color: DCColors.white),
                                        ),
                                      )),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(CriarUsuario());
                                  // Implementar navegação para criar usuário
                                },
                                child: Text(
                                  "Criar usuário",
                                  style: DCTheme.h2.copyWith(
                                    color: DCColors.iron100,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                },
                                child: Text(
                                  "Recuperar senha",
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
      ),
    );
  }
}
