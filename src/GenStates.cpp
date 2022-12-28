#include <random>
#include <fstream>
#include <filesystem>
#include <boost/numeric/odeint.hpp>

#include "matrices/Matrices.hpp"

int main(int argc, char **argv)
{
  using namespace std;
  using namespace boost::numeric::odeint;

  const string f_file = "./external/F/N" + to_string(N) + ".dat";
  const f_type masterF(f_file);

  string filename = randomName();

  auto state = randomStateFixedEnergy(1.0, masterF);

  saveState(state, "./runs/States/" + filename + ".dat");

  return (EXIT_SUCCESS);
}