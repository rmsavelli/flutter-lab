import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enviar Email Gmail SMTP',
      home: const EmailSender(),
    );
  }
}

class EmailSender extends StatefulWidget {
  const EmailSender({super.key});

  @override
  State<EmailSender> createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {
  String _status = "Pressione o botão para enviar email";

  Future<void> sendEmail() async {
    final username = 'rsavelli@gmail.com';
    final password = 'bale xhzg qiiq tvqf';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Rafael Savelli')
      ..recipients.add('rafael.savelli@luklagroup.com')
      ..subject = 'Teste Flutter Email via SMTP'
      ..text = 'Este é um email enviado pelo app Flutter usando SMTP do Gmail.';

    try {
      final sendReport = await send(message, smtpServer);
      setState(() {
        _status = 'Email enviado com sucesso: ' + sendReport.toString();
      });
    } on MailerException catch (e) {
      setState(() {
        _status = 'Erro ao enviar email: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Email via SMTP Gmail'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_status),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendEmail,
                child: const Text('Enviar Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}