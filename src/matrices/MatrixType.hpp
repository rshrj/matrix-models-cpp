#ifndef MATRIX_TYPE_HPP_INCLUDED
#define MATRIX_TYPE_HPP_INCLUDED

#include <fstream>
#include <ostream>
#include <string>
#include <boost/operators.hpp>
#include <boost/multi_array.hpp>

template <class T, size_t Ndim>
class matrix : 
  boost::additive1< matrix<T, Ndim>,
  boost::additive2< matrix<T, Ndim>, T,
  boost::multiplicative2< matrix<T, Ndim>, T
  > > >
{
  public:
    
    const static size_t N = Ndim;
    const static size_t dim = N * N - 1;

    typedef T value_type;
    typedef matrix<value_type, N> matrix_type;

    // ...
    // constructors
    //<-

    matrix(void)
    {
        for( size_t i=0 ; i<dim ; ++i ) m_val[i] = 0.0;
    }


    matrix( value_type val)
    {
        for( size_t i=0 ; i<dim ; ++i ) m_val[i] = val;
    }

    matrix( boost::array<value_type, dim> val)
    {
        for( size_t i=0 ; i<dim ; ++i ) m_val[i] = val[i];
    }
    //->


    // ...
    // operators
    //<-
    T operator[]( size_t i ) const { return m_val[i]; }
    T& operator[]( size_t i ) { return m_val[i]; }

    matrix_type& operator+=( const matrix_type& p )
    {
        for( size_t i=0 ; i<dim ; ++i )
            m_val[i] += p[i];
        return *this;
    }

    matrix_type& operator-=( const matrix_type& p )
    {
        for( size_t i=0 ; i<dim ; ++i )
            m_val[i] -= p[i];
        return *this;
    }

    matrix_type& operator+=( const value_type& val )
    {
        for( size_t i=0 ; i<dim ; ++i )
            m_val[i] += val;
        return *this;
    }

    matrix_type& operator-=( const value_type& val )
    {
        for( size_t i=0 ; i<dim ; ++i )
            m_val[i] -= val;
        return *this;
    }

    matrix_type& operator*=( const value_type &val )
    {
        for( size_t i=0 ; i<dim ; ++i )
            m_val[i] *= val;
        return *this;
    }

    matrix_type& operator/=( const value_type &val )
    {
        for( size_t i=0 ; i<dim ; ++i )
            m_val[i] /= val;
        return *this;
    }

    //->

  private:

    T m_val[dim];
};

//...
// more operators
//]


template<class T, size_t N>
class foo {
  public:
    const static size_t dim = N * N - 1;

    foo (std::string file) {
      std::ifstream fin (file);

      double temp = 0;

      size_t a = 0;
      size_t b = 0;
      size_t c = 0;
      
      bool reached_end = false;

      while (fin >> temp && !reached_end) {
        m_f[a][b][c] = temp;
        if (c == dim - 1) {
          if (b == dim - 1) {
            if (a == dim - 1) {
              reached_end = true;
            } else {
              ++a;
              b = 0;
              c = 0;
            }
          } else {
            ++b;
            c = 0;
          }
        } else {
          ++c;
        }
      }
    }

    // commutator

    matrix<T, N> comm(const matrix<T, N>& p1, const matrix<T, N>& p2) const
    {
        matrix<T, N> tmp = p1;
        T s;

        for( size_t i=0 ; i<tmp.dim ; ++i ) {
          s = 0;
          for ( size_t j=0; j<tmp.dim; ++j) {
            for (size_t k=j+1; k<tmp.dim; ++k) {
              s += m_f[i][j][k] * (p1[j] * p2[k] - p2[j] * p1[k]);
            }
          }
          tmp[i] = s;
        }
        return tmp;
    }

    T f(const int i, const int j, const int k) const {
      return m_f[i][j][k];
    }

  private:
    T m_f[dim][dim][dim];

};

//
// the - operator
//
template< class T , size_t Dim >
matrix< T , Dim > operator-( const matrix< T , Dim > &p )
{
    matrix< T , Dim > tmp = p;
    for( size_t i=0 ; i<tmp.dim ; ++i ) tmp[i] = -p[i];
    return tmp;
}

//
// scalar product
//
template< class T , size_t Dim >
T scalar_prod( const matrix< T , Dim > &p1 , const matrix< T , Dim > &p2 )
{
    T tmp = 0.0;
    for( size_t i=0 ; i<p1.dim ; ++i ) tmp += 0.5 * p1[i] * p2[i];
    return tmp;
}

//
// norm
//
template< class T , size_t Dim >
T norm( const matrix< T , Dim > &p1 )
{
    return scalar_prod( p1 , p1 );
}

//
// absolute value
//
template< class T , size_t Dim >
T abs( const matrix< T , Dim > &p1 )
{
    return sqrt( norm( p1 ) );
}

//
// output operator
//
template< class T , size_t Dim >
std::ostream& operator<<( std::ostream &out , const matrix< T , Dim > &p )
{
    if( Dim > 0 ) out << p[0];
    for( size_t i=1 ; i<p.dim ; ++i ) out << " " << p[i];
    return out;
}

#endif //MATRIX_TYPE_HPP_INCLUDED