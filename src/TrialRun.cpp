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

  ofstream outfile;
  string filename = randomName();

  string outdir = "./runs/Trial";
  filesystem::create_directories(outdir);

  outfile.open(outdir + "/" + filename + ".dat");

  auto state = randomStateFixedEnergy(1.0, masterF);

  container_type q = state.first;
  container_type p = state.second;

  typedef symplectic_rkn_sb3a_mclachlan<container_type> stepper_type;

  const double start_time = 0.0;
  const double end_time = 10.0;
  const double dt = 0.1;

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