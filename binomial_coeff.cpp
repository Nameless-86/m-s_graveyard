#include <iostream>

using namespace std;

int factorial(int n)
{
  if (n == 0)
  {
    return 1;
  }
  return n * factorial(n - 1);
}

int binomial(int n, int k)
{
  if ((k < 0) || (k > n))
  {
    return 0;
  }
  else if (k > n - k)
  {
    k = n - k;
  }
  if ((k == 0) || (k == n))
  {
    return 1;
  }
  else
    return binomial(n - 1, k - 1) + binomial(n - 1, k);
}

int main()
{
  int n, k;
  cout << "Introduce a number n: ";
  cin >> n;
  cout << "Introduce a number k: ";
  cin >> k;
  cout << "result: " << binomial(n, k);
  return 0;
}