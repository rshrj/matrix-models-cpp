#ifndef MATRIX_HPP_INCLUDED
#define MATRIX_HPP_INCLUDED

#include <iostream>
#include <string>

#include "MatrixType.hpp"

template <size_t N>
using matrix_type = matrix<double, N>;

template <size_t N>
using f_type = foo<double, N>;

template <size_t N, size_t K>
using container_type = boost::array<matrix_type<N>, K>;

template <size_t N, size_t K>
struct bfss_coor
{
  bfss_coor(void) {}

  void operator()(const container_type<N, K> &p, container_type<N, K> &dqdt) const
  {
    for (size_t i = 0; i < K; ++i)
    {
      dqdt[i] = p[i];
    }
  }
};

template <size_t N, size_t K>
struct bfss_momentum
{

  const f_type<N> &m_F;

  bfss_momentum(const f_type<N> &F) : m_F(F) {}

  void operator()(const container_type<N, K> &q, container_type<N, K> &dpdt) const
  {
    for (size_t k = 0; k < K; ++k)
    {
      dpdt[k] = 0.0;
      for (size_t i = 0; i < K; ++i)
      {
        dpdt[k] += m_F.comm(m_F.comm(q[k], q[i]), q[i]);
      }
    }
  }
};

template <size_t N, size_t K>
struct streaming_observer_elements
{
  std::ostream &m_out;

  streaming_observer_elements(std::ostream &out) : m_out(out) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type<N, K> q = s.first;
    m_out << t;
    for (size_t i = 0; i < K; ++i)
      m_out << "    " << q[i];
    m_out << "\n";
  }
};

template <size_t N, size_t K>
struct streaming_observer_elements_with_momenta
{
  std::ostream &m_out;

  streaming_observer_elements_with_momenta(std::ostream &out) : m_out(out) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type<N, K> q = s.first;
    container_type<N, K> p = s.second;
    m_out << t;
    for (size_t i = 0; i < K; ++i)
      m_out << "    " << q[i];
    m_out << "    ";
    for (size_t i = 0; i < K; ++i)
      m_out << "    " << p[i];
    m_out << "\n";
  }
};

template <size_t N, size_t K>
double radius(const container_type<N, K> &q);

template <size_t N, size_t K>
double energy(const container_type<N, K> &q, const container_type<N, K> &p, const f_type<N> &F);

template <size_t N, size_t K>
struct streaming_observer_energy
{
  std::ostream &m_out;
  const f_type<N> &m_F;

  streaming_observer_energy(std::ostream &out, const f_type<N> &F) : m_out(out), m_F(F) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type<N, K> q = s.first;
    container_type<N, K> p = s.second;
    m_out << t << " " << energy(q, p, m_F);
    m_out << "\n";
  }
};

template <size_t N, size_t K>
struct streaming_observer_radius
{
  std::ostream &m_out;

  streaming_observer_radius(std::ostream &out) : m_out(out) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type<N, K> q = s.first;
    m_out << t << " " << radius(q);
    m_out << "\n";
  }
};

template <size_t N>
boost::array<double, N * N - 1> randomState();

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> randomStateFixedEnergy(const double, const f_type<N>);

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> loadState(std::string);

template <size_t N, size_t K>
void saveState(std::pair<container_type<N, K>, container_type<N, K>>, std::string);

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> perturbRandomly(std::pair<container_type<N, K>, container_type<N, K>>, double, const f_type<N>);

template <size_t N, size_t K>
std::pair<container_type<N, K>, container_type<N, K>> rSFEI(const double, const f_type<N>);

std::string randomName();

#include "Matrices_Impl.hpp"

#endif //MATRIX_HPP_INCLUDED