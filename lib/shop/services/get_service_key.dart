import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "emechanicfyp-8f13f",
          "private_key_id": "6f54c3f457564310a25942b50e85660ea5b9ecd1",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCUOvA5MmWJjCYT\nw/H15wzd8H2tDLYE84a/hmRcN8bFadUswCMEt6UNys1z5g4EZ4YmwxSSAdxnjMf5\njABgBlS+Rvnu1R5AjxPR4wcA2YPDaN5p92jns27mN34LIk0HdGLb4C4kwcWX9FLa\nXJ7pV3ikE8gQiDd0cTfK2N3/CPRR4M+7s+o+N257Jkt3vwaz5pNT5OPnp7E0kP0w\npYAZpOLnKVYud4GznRthhMNTPRaD6n+VkrX9R1oigXldDFd5vIkn/4DeL4F6kBro\n5lLgIll3UEWZDhY77adggwaNYe5/8zDcfZkAgsz0f0m3pxdCQNQR4ax9gngnVYC4\nbeX1iSFpAgMBAAECggEAAjiX3OOKbfMxpt4qw/qAUNsHpw4ntA9KF5iV7GPRkKez\nUAZY//sYeApv5aquzxYWBoKpzj5E5TBQ1sZoQwgVQPyjRhbfayw5qc1zD2oy9Tyf\nCItygPZJVR3Dv7r12IS/7nd/eYGFym8YxrjYkLqEzkCVoNnJqu7/XQS+3tFth8SG\nwdWSXzkVplK1QBzScnWk9PsUDYStBW2gKCBQBGDhw9Y/BPaYywkMdXMOxZYaFAau\n6xdE4awhLgQaYi4/LYuJko37gA/rQnLKfXPqBkkRLwi8Jsv+eDADCF60noNL2G7x\nRZieb65x09GxcYE+kMiTB6OreMlG9zZ9AEtrAh9xOQKBgQDDkpjwTSo8smN47ang\nhCF0Vfb+bRRFRaRJTp/IMsAe+UmsgLESPRUkRFu7KtJJrIC31vh0bcxBxFpb8zqh\nP2YSHci5GIGekd8KCCNMctzDp+wNp2m89hA2C7VnYfSupNaBGjKzry4+a8zz/7jF\nUr8jGyzuqVRO79aKJU5MkN2efwKBgQDCB6anWwjLv0hoe/x/h9w20AnIIC+ySwqH\noT+OAtBk2YlpO7EfQ/9+i0xtqPi0TZGuQWvcKpcHH8YIe+dBfe5rBiiwTFkT0sfD\nIMlrAIoGZyK8f2u1gr3XbFVyA01Z/uHYztWTYcj0IqFSRyHrNykav8c4wbyQUsAU\nnGYq+rYcFwKBgQCdWT0jWXI6E2xkxxJ+SNCBwQhP+4LrmPRs5o03jV11jivwVjog\n6nQwEa+cDv/RtrB5OMP9KLnF0CzC/haV1WRR/xSXl1fyNHq2n4WG5IMqB9irw54X\nIgI4+YKiAvXR7V2H0YQpfTA/mIv1ZDFM0R5nKF4mRqZGPEDoNMuiXotwEQKBgQC1\nRoqn/sA4Ay02GOhtidPvDeyloZSOQdfDoZ4MIorqPedIfvFbYZ8ZbjFonp5Fbdc2\nc36/Ard5e3D8Si5jnLEcInPvSlVK1Pm3TzF/G9DYbJEihPVvbofI9TjbPUSOWThN\n4+fcO1aQ6K3JfhWteSqZCCWr3C08tWMpnnlBnFx53wKBgH6yd0UQYvzNYsklTJKJ\np+AkNEjICX3/oa+oPfs2PzDUzcVf7Wj4Koxrv1DPYC/bSJHQywr7xPnnAGh0ptBo\nB0yXdoNb7DUFUXbk4nZTiYCp6y7Dr80r2H1vRF26tPCk7s5XAopuYNeke/EYhT1A\nKYt4Q/aV4mIHrAQvKkWLEZ0w\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-obcqq@emechanicfyp-8f13f.iam.gserviceaccount.com",
          "client_id": "112153675376049809098",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-obcqq%40emechanicfyp-8f13f.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServeryKey = client.credentials.accessToken.data;
    return accessServeryKey;
  }
}
