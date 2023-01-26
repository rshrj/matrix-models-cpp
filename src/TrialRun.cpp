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

  // const size_t N = 2;
  // const size_t K = 2;
  // if (argc == 3)
  // {
  //   try
  //   {
  //     if (N < 2 || K < 2)
  //     {
  //       cerr << "N, K must be >= 2" << endl;
  //       return (EXIT_FAILURE);
  //     }
  //   }
  //   catch (invalid_argument &e)
  //   {
  //     cerr << "Invalid (N, K)" << endl;
  //     return (EXIT_FAILURE);
  //   }
  // } else {
  //   cerr << "Specify (N, K)" << endl;
  //   return (EXIT_FAILURE);
  // }

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

  ofstream outfile;

  string outdir = "./runs/Trials/N" + to_string(N) + "K" + to_string(K) + "/";
  filesystem::create_directories(outdir);

  outfile.open(outdir + pickedState);

  auto state = loadState<N, K>("./runs/States/N" + to_string(N) + "K" + to_string(K) + "/" + pickedState);

  container_type<N, K> q = state.first;
  container_type<N, K> p = state.second;

  typedef symplectic_rkn_sb3a_mclachlan<container_type<N, K>> stepper_type;

  const double start_time = 0.0;
  const double end_time = 1000.0;
  const double dt = 0.1;

  integrate_const(
      stepper_type(),
      make_pair(bfss_coor<N, K>(), bfss_momentum<N, K>(masterF)),
      make_pair(boost::ref(q), boost::ref(p)),
      start_time,
      end_time,
      dt,
      streaming_observer_elements_with_momenta<N, K>(outfile));

  return (EXIT_SUCCESS);
}
