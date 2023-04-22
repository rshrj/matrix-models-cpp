#include <random>
#include <fstream>
#include <filesystem>
#include <boost/numeric/odeint.hpp>

#include "matrices/Matrices.hpp"

int main(int argc, char **argv)
{
  using namespace std;
  using namespace boost::numeric::odeint;

  const size_t N = 9;
  const size_t K = 9;

  const string f_file = "./external/F/N" + to_string(N) + ".dat";
  const f_type<N> masterF(f_file);

  std::string pickedState = "";
  if (argc == 2)
  {
    try
    {
      pickedState = argv[1];
      if (!filesystem::exists("./runs/States/N" + to_string(N) + "K" + to_string(K) + "/" + pickedState))
      {
        cerr << "Invalid file" << endl;
        return (EXIT_FAILURE);
      }
    }
    catch (invalid_argument &e)
    {
      cerr << "Invalid file" << endl;
      return (EXIT_FAILURE);
    }
  } else {
    cerr << "Invalid argument" << endl;
    return (EXIT_FAILURE);
  }

  auto fstate = loadState<N, K>("./runs/States/N" + to_string(N) + "K" + to_string(K) + "/" + pickedState);

  string filename = randomName();

  auto state = perturbRandomly<N, K>(fstate, pow(10, -6), masterF);

  string outdir = "./runs/States/N" + to_string(N) + "K" + to_string(K) + "/";
  filesystem::create_directories(outdir);
  saveState<N, K>(state, outdir + filename + ".dat");

  return (EXIT_SUCCESS);
}