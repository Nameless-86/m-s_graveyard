#include <iostream>
#include <vector>
using namespace std;

int distintos(){
    return k;
}
int periodo(){
    return p;
}

vector<int> gcl(int a, int s, int m, int d, int b)
{

  vector<int> r;
  r.resize(m);
  r[0] = s;
  for (int i = 1; i < r.size(); i++)
  {
    r[i] = (a * r[i - 1] + b) % d;
  }
  return r;
}

int main()
{
  int a;
  int s;
  int m;
  int d;
  int b;

  cout << "ingresa a: multiplicador del generador ";
  cin >> a;
  cout << "ingresa seed s: semilla inicial (valor de r_0)";
  cin >> s;
  cout << "m: cantidad de valores a generar: ";
  cin >> m;
  cout << "d: modulo del generador: ";
  cin >> d;
  cout << "b: incremento del generador: ";
  cin >> b;

  vector<int> result = gcl(a, s, m, d, b);
  for (int i = 0; i < result.size(); i++)
  {
    cout << result[i] << "\n";
  };
}

// # Glosario:
//a=23, s=21, m=60, d=53, b=0.
// # - Formula: r_(i+1) = (a * r_i + b) mod d
// # - GCL: generador congruencial lineal. vamos a obtener los numeros
// siguientes en base a los anteriores # - r_i: i-esimo numero entero generado
// por el GCL. () # - a: multiplicador del generador. entero positivo que no
// tenga factores comunes con m, evitar multiplos de 2 # - b: incremento del
// generador (aca b = 0).se recomienda un valor impar y pequeño # - d: modulo
// del generador (aca d = 53). tiene que ser un primo grande o potencia de dos
// para garantizar buena distribucion de los numeros generados, evita ciclos
// cortos # un modulo chico puede dar un ciclo corto y secuencia repetitiva # -
// s: semilla inicial (valor de r_1). necesitas arrancar con un numero menor a d
// # - m: cantidad de valores a generar.
// # - u_i: version reescalada de r_i al intervalo (0, 1).
// # - distintos: cantidad de valores no repetidos en la secuencia, medida con
// length(unique(r)). # b = 0 implica un generador multiplicativo y ri no puede
// tomar el valor 0
//