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

  std::string pickedState = "";
  if (argc == 2)
  {
    try
    {
      pickedState = argv[1];
      if (!filesystem::exists("./runs/States/" + pickedState + ".dat"))
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

  ofstream outfile;
  string filename = randomName();

  string outdir = "./runs/Trials/" + pickedState;
  filesystem::create_directories(outdir);

  outfile.open(outdir + "/" + filename + ".dat");

  auto state0 = loadState("./runs/States/" + pickedState + ".dat");
  auto state = perturbRandomly(state0, pow(10, -6), masterF);

  container_type q = state.first;
  container_type p = state.second;

  typedef symplectic_rkn_sb3a_mclachlan<container_type> stepper_type;

  const double start_time = 0.0;
  const double end_time = 1.0;
  const double dt = 0.3;

  integrate_const(
      stepper_type(),
      make_pair(bfss_coor(), bfss_momentum(masterF)),
      make_pair(boost::ref(q), boost::ref(p)),
      start_time,
      end_time,
      dt,
      streaming_observer_elements_with_momenta(outfile));

  return (EXIT_SUCCESS);
}