#include <random>
#include <boost/numeric/odeint.hpp>

#include "matrices/Matrices.hpp"

template <size_t N, size_t K>
double radius(const container_type<N, K> &q)
{
  double sum = 0.0;
  for (size_t i = 0; i < K; ++i)
    sum += 0.5 * norm(q[i]);
  return sum;
}

template <size_t N, size_t K>
double energy(const container_type<N, K> &q, const container_type<N, K> &p, const f_type<N> &F)
{
  double sum = 0.0;
  for (size_t i = 0; i < K; ++i)
    sum += 0.5 * norm(p[i]);

  for (size_t i = 0; i < K; ++i)
    for (size_t j = i + 1; j < K; ++j)
      sum += 0.5 * norm(F.comm(q[i], q[j]));

  return sum;
}

template <size_t N>
boost::array<double, N * N - 1> randomState()
{
  std::random_device rd;
  std::mt19937 gen(rd());

  std::uniform_real_distribution<> dist(-1.0, 1.0);

  boost::array<double, N * N - 1> state;

  for (size_t i = 0; i < state.size(); ++i)
  {
    state[i] = dist(gen);
  }

  return state;
}

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> randomStateFixedEnergy(const double E, const f_type<N> F)
{
  container_type<N, K> q;
  for (size_t k = 0; k < K; ++k)
  {
    q[k] = randomState<N>();
  }

  container_type<N, K> p;
  for (size_t k = 0; k < K; ++k)
  {
    p[k] = 0.0;
  }

  double eRatio = E / energy(q, p, F);

  for (size_t k = 0; k < K; ++k)
  {
    q[k] = q[k] * pow(eRatio, 0.25);
  }

  return std::make_pair(q, p);
}

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> loadState(std::string stateFile)
{
  std::ifstream fin (stateFile);

  std::string tempStr;

  container_type<N, K> q, p;

  for (size_t k = 0; k < K; ++k)
  {
    boost::array<double, N*N-1> tempArr;
    for (size_t i = 0; i < N*N-1; ++i)
    {
      fin >> tempStr;
      tempArr[i] = stod(tempStr);
    }
    q[k] = matrix_type<N>(tempArr);
  }

  for (size_t k = 0; k < K; ++k)
  {
    boost::array<double, N*N-1> tempArr;
    for (size_t i = 0; i < N*N-1; ++i)
    {
      fin >> tempStr;
      tempArr[i] = stod(tempStr);
    }
    p[k] = matrix_type<N>(tempArr);
  }

  // for (size_t k = 0; k < K; ++k)
  // {
  //   std::cout << q[k] << std::endl;
  // }

  // std::cout << std::endl;

  // for (size_t k = 0; k < K; ++k)
  // {
  //   std::cout << p[k] << std::endl;
  // }

  return std::make_pair(q, p);
}

template <size_t N, size_t K>
void saveState(std::pair<container_type<N, K>, container_type<N, K>> state, std::string stateFile)
{
  container_type<N, K> q = state.first;
  container_type<N, K> p = state.second;

  std::ofstream outfile;

  outfile.open(stateFile);

  outfile << q[0];
  for (size_t i = 1; i < K; ++i)
    outfile << "    " << q[i];
  outfile << "    ";
  for (size_t i = 0; i < K; ++i)
    outfile << "    " << p[i];

  outfile.close();
}

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> perturbRandomly(std::pair<container_type<N, K>, container_type<N, K>> state, double epsilon, const f_type<N> F)
{
  container_type<N, K> q = state.first;
  container_type<N, K> p = state.second;

  for (size_t k = 0; k < K; ++k)
  {
    q[k] += epsilon * matrix_type<N>(randomState<N>());
  }

  double eRatio = 1.0 / energy(q, p, F);

  for (size_t k = 0; k < K; ++k)
  {
    q[k] = q[k] * pow(eRatio, 0.25);
  }

  return std::make_pair(q, p);

}

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> rSFEI(const double E, const f_type<N> F)
{
  container_type<N, K> q;
  for (size_t k = 0; k < K; ++k)
  {
    q[k] = randomState<N>();
  }

  container_type<N, K> p;
  for (size_t k = 0; k < K; ++k)
  {
    p[k] = randomState<N>();
  }

  double eRatio = E / energy(q, p, F);

  for (size_t k = 0; k < K; ++k)
  {
    q[k] = q[k] * pow(eRatio, 0.25);
  }

  for (size_t k = 0; k < K; ++k)
  {
    p[k] = p[k] * pow(eRatio, 0.50);
  }

  return std::make_pair(q, p);
}

std::string randomName()
{
  std::random_device rd;
  std::mt19937 gen(rd());

  std::uniform_int_distribution<> dist(10000000, 99999999);

  return std::to_string(dist(gen));
}