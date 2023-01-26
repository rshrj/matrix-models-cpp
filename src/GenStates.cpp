#include <random>
#include <fstream>
#include <filesystem>
#include <boost/numeric/odeint.hpp>

#include "matrices/Matrices.hpp"

int main(int argc, char **argv)
{
  using namespace std;
  using namespace boost::numeric::odeint;

  const size_t N = 2;
  const size_t K = 2;

  const string f_file = "./external/F/N" + to_string(N) + ".dat";
  const f_type<N> masterF(f_file);

  string filename = randomName();

  auto state = randomStateFixedEnergy<N, K>(1.0, masterF);

  saveState<N, K>(state, "./runs/States/" + filename + ".dat");

  return (EXIT_SUCCESS);
}