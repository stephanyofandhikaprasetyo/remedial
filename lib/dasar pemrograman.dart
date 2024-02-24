
double tambah(double x, double y) {
  return x + y;
}

double kurang(double x, double y) {
  return x - y;
}

double kali(double x, double y) {
  return x * y;
}

double bagi(double x, double y) {
  return x / y;
}

void hasil(double z) {
  print('hasil : $z');
}

void main() {
  double a1 = 5;
  double a2 = 2;
  String op = '+';

  if (op == '+') {
    hasil(tambah(a1, a2));
  }

  if (op == '-') {
    hasil(kurang(a1, a2));
  }

  if (op == '*') {
    hasil(kali(a1, a2));
  }

  if (op == '/') {
    hasil(bagi(a1, a2));
  }
}