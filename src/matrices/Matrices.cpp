#include <random>
#include <boost/numeric/odeint.hpp>

#include "matrices/Matrices.hpp"

double radius(const container_type &q)
{
  double sum = 0.0;
  for (size_t i = 0; i < K; ++i)
    sum += 0.5 * norm(q[i]);
  return sum;
}

double energy(const container_type &q, const container_type &p, const f_type &F)
{
  double sum = 0.0;
  for (size_t i = 0; i < K; ++i)
    sum += 0.5 * norm(p[i]);

  for (size_t i = 0; i < K; ++i)
    for (size_t j = i + 1; j < K; ++j)
      sum += 0.5 * norm(F.comm(q[i], q[j]));

  return sum;
}

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

std::pair<container_type, container_type> randomStateFixedEnergy(const double E, const f_type F)
{
  container_type q;
  for (size_t k = 0; k < K; ++k)
  {
    q[k] = randomState();
  }

  container_type p;
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

std::pair<container_type, container_type> rSFEI(const double E, const f_type F)
{
  container_type q;
  for (size_t k = 0; k < K; ++k)
  {
    q[k] = randomState();
  }

  container_type p;
  for (size_t k = 0; k < K; ++k)
  {
    p[k] = randomState();
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