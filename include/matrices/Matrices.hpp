#ifndef MATRIX_HPP_INCLUDED
#define MATRIX_HPP_INCLUDED

#include <iostream>
#include <string>

#include "MatrixType.hpp"

const size_t N = 8;
const size_t K = 3;

typedef matrix<double, N> matrix_type;
typedef foo<double, N> f_type;
typedef boost::array<matrix_type, K> container_type;

struct bfss_coor
{
  bfss_coor(void) {}

  void operator()(const container_type &p, container_type &dqdt) const
  {
    for (size_t i = 0; i < K; ++i)
    {
      dqdt[i] = p[i];
    }
  }
};

struct bfss_momentum
{

  const f_type &m_F;

  bfss_momentum(const f_type &F) : m_F(F) {}

  void operator()(const container_type &q, container_type &dpdt) const
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

struct streaming_observer_elements
{
  std::ostream &m_out;

  streaming_observer_elements(std::ostream &out) : m_out(out) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type q = s.first;
    m_out << t;
    for (size_t i = 0; i < K; ++i)
      m_out << "    " << q[i];
    m_out << "\n";
  }
};

struct streaming_observer_elements_with_momenta
{
  std::ostream &m_out;

  streaming_observer_elements_with_momenta(std::ostream &out) : m_out(out) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type q = s.first;
    container_type p = s.second;
    m_out << t;
    for (size_t i = 0; i < K; ++i)
      m_out << "    " << q[i];
    m_out << "    ";
    for (size_t i = 0; i < K; ++i)
      m_out << "    " << p[i];
    m_out << "\n";
  }
};

double radius(const container_type &q);

double energy(const container_type &q, const container_type &p, const f_type &F);

struct streaming_observer_energy
{
  std::ostream &m_out;
  const f_type &m_F;

  streaming_observer_energy(std::ostream &out, const f_type &F) : m_out(out), m_F(F) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type q = s.first;
    container_type p = s.second;
    m_out << t << " " << energy(q, p, m_F);
    m_out << "\n";
  }
};

struct streaming_observer_radius
{
  std::ostream &m_out;

  streaming_observer_radius(std::ostream &out) : m_out(out) {}

  template <class State>
  void operator()(const State &s, double t) const
  {
    container_type q = s.first;
    m_out << t << " " << radius(q);
    m_out << "\n";
  }
};

boost::array<double, N * N - 1> randomState();

std::pair<container_type, container_type> randomStateFixedEnergy(const double E, const f_type F);

std::pair<container_type, container_type> rSFEI(const double E, const f_type F);

std::string randomName();

#endif //MATRIX_HPP_INCLUDED