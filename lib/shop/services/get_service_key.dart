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
          "private_key_id": "aa5730dee778f740640c38340bce5d0f7e93ac9a",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDqmedhs+dB++bE\n8ZdWfIPkkQW6ye61NUEn7tXFwr+30E4W0Smzz0LCRM1oat3HLkjWWLHT/cnjm0f9\nTHhODb9FiozhONlZ1+pM3QnSpToq+xcDh7icLNPRp5kFWKQcHlRUP/ZzX92SSswm\nrxAh1I7sr4GeKhvmQWtNveBeuKYNgqbdjam6tOJHsCf1DSc606kY+jmuj104N1MY\nWVN0p1TxZbrUKdI4MXiXxaJlc9BASMSGvEW3EZK+Pm2P0NrQUMCI5trtwLo6wQ8x\ndb+JVLH7pXbZeFhBPwLQ+gna8G9IJQqQeMJaNbuAU47ZRqtGEgXczOZLFOArPWKX\nQQKsW2nJAgMBAAECggEAB9OzqwhQBl0LoXV3+Zw04ErQWJ+FFcmdj2ICAtORBuZt\nvIgk7olTLl0SR1INbShHqNMTt8FnW28iUzqaZuxBfeX19kupwLwZ5o+XVM5LZwSy\ni10bVSaPuJZxXgLLkt6WLKtnowjHQSq6re24SZCoZhAi8G5yONfk5xaXJkHd1GR/\npYdFmnGfhziGajX950SaveGu2UGysIPaxEhPpJIbdey3uk40nigZUmN933WZ7jg2\nrhdJoQDWgQiF5u8gE2Fbxm6PTEbN1CH6guiXV4L9n4MzWvLwxpLWTQ3KfOROQXf6\nw7agOrir4CjO6z+UNaY4DCtNwUSN8cVreU6slWVriwKBgQD8nsBHQSKZHBfPKZTd\ndfYWpawnNabPIh6JRIe1sj4hRRcuDx3a7Q0Mq31gLTt7hEjeIJeT0Un684iezM6Z\nSU39jxQJvd32pzSDNnP63xkLfCbvf3llA8UHguEr/LL+jSCD3T0lzdyLUC3wFy3t\nmLK+QykTOILbGntKos9XxYnzOwKBgQDtvW+lILz3LCydjYtb8eH2Jb80feECcOOK\npUUCZ8KXIW01IYyl8AbrXkiUTMVeiB2IlKDzqeVjtJQYeE6moIrZ8tFin0cIT5r9\nVEUeoWm01xehCJbWfq2SLZiZLZZY0EyQGkcmmxzDNFci/uvJTNirt+xOpPIAlAXp\n+Tof+bn+ywKBgEb/iwS7rrCfb6WehyMyywYUa+zdLFOcwD5OD2ImhUWueFROlVJ5\nOyirbeJA9C3DwQME3/UAZi1skqIm5423R38S3kvam+59kcmq3S/N0ekjbIH1LrYQ\nOCjjRMurCtd17ISDAnOEhw50a2TF7veO6fWFRJ8NS+GucKZKWcHOV/YPAoGAFLw1\nBJ36XUSJD6TMxtQt9R4NszJXcbMO5YTMpA0Qt8W+lKe8cKyirdynT+fyPvB4QvVT\npGzpCO0zDX9QvM+7zI6VHJjvxRXMWtQCw00ovxETioQJQ+QAl4NKj/Gd71kblGX2\nVrOoqo3iG7dIMWJ2c2OzRJi2Ur6WVXXbT/aj9kkCgYB6SoSLuibEGXZz+oJSVYD1\n+wYdTZx2++e60QAA4599oeYF0xq9JlgzE1I1+wmEQpCrO6Zxoiey6ydMoM8MYLtv\nkBiMFzOBYjQ6clU2rfWIzNHedFBjycRcZmKtLc3SQWrZzNImeAwKGy471rgr3zGW\n8w1YYAlCpihHHbRfBu19Og==\n-----END PRIVATE KEY-----\n",
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
