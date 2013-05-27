/** @author Sameer Sheorey */
#include  <cmath>
#include  "lift.h"
#include  <vector>
using std::vector;
#include  "wemd.h"

#include  "portable_time.h"

using namespace blitz;

void test_lwt1() {

  const int dim = 1;            // problem dimension
  LS<double> wav("db2");        // Select pre-defined wavelet. see lifting-schemes.h
  LS<double>::extMode<dim>() = periodic; // periodic extension or zero padding ?
  vector<Array<TinyVector<double, 1>, 1> > Y(1);  // Holds output of LWT

  wav.display<dim>(cout);

  Array<double, dim> X(4), Xcopy(4);  // Input data
  Xcopy = X = 1 + 3*tensor::i;        // See Blitz++ documentation 

  double n1 = sum(sqr(X)), na, nd0, nd1=0;  

  cout << "X = " << X << endl;
  wav.lwt<dim>(X, Y);               // Compute wavelet transform
  cout << "LWT(X) (app) = " << X << endl;
  cout << "LWT(X) (det0) = " << Y[0][0] << endl;
//  cout << "LWT(X) (det1) = " << Y[1][0] << endl;
  na = sum(sqr(X)); nd0 = sum(sqr(Y[0][0])); // nd1 = sum(sqr(Y[1][0])); 
  cout << "signal norm = " << sqrt(n1) << endl <<
    "WT norm = " << sqrt(na+nd0+nd1) << endl;

  TinyVector<bool, 1> szodd = Xcopy.extent()%2==1;
  wav.ilwt<dim>(X, Y, szodd);
  cout << "Reconstruct X = " << X << endl;
  assert(fabs(n1-na-nd0-nd1) <= 1e-6);
  assert(sqrt(sum(sqr(X-Xcopy))) <= 1e-6 );
}

void test_lwt2() {

  const int dim = 2;
  LS<double> wav("coif2");
  LS<double>::extMode<dim>() = periodic, zpd;
  vector<Array<TinyVector<double, (1<<dim) - 1>, dim> > Y(2);

  wav.display<dim>(cout);

  Array<double, dim> X(4,6), Xcopy(4,6);
  Xcopy = X = 1 + 2*tensor::i + 3*tensor::j;
  cout << X << endl;

  double n1 = sum(sqr(X)), na, nd0, nd1;

  wav.lwt<dim>(X, Y);
  cout << "LWT(X) (app) = " << X << endl;
  cout << "LWT(X) (det0) = " << Y[0][0] << Y[0][1] << Y[0][2] << endl;
  cout << "LWT(X) (det1) = " << Y[1][0] << Y[1][1] << Y[1][2] << endl;
  na = sum(sqr(X)); nd0 = sum( sqr(Y[0][0]) + sqr(Y[0][1]) + sqr(Y[0][2]) );
  nd1 = sum( sqr(Y[1][0]) + sqr(Y[1][1]) + sqr(Y[1][2]) ); 
  cout << "signal norm = " << sqrt(n1) << endl <<
    "WT norm = " << sqrt(na+nd0+nd1) << endl;
  assert(fabs(n1-na-nd0-nd1) <= 1e-4);

  TinyVector<bool, dim> szodd = Xcopy.extent()%2==1;
  wav.ilwt<dim>(X, Y, szodd);
  cout << "Reconstruct X = " << X << endl;
  assert(sqrt(sum(sqr(X-Xcopy))) <= 1e-4 ); 
}

void test_lwt3() {

  const int dim = 3;
  const int ncmps = (1<<dim)-1;
  const int J=3;
  const int REP=1;
  LS<double> wav("sym2");
  LS<double>::extMode<dim>() = zpd;
  vector<Array<TinyVector<double, (1<<dim) - 1>, dim> > Y(J);

  wav.display<dim>(cout);

  double n1=0, na=0, dt=0, t;
  TinyVector<double, J> nd=0.0;
  Array<double, dim> X, Xcopy;

  for(int k=0; k<REP; ++k)
  {
    X.resize(16,16,16);
    Xcopy.resize(X.extent());
    Xcopy = X = 1 + 2*tensor::i + 3*tensor::j + 5*tensor::k;
    n1 = sum(sqr(X));
  //X = 1, -1;
  //Xcopy = X;
  //cout << X << endl;

    t = timer();
    wav.lwt<dim>(X, Y);
    dt += timer()-t;
    //display(cout, X, Y);
    na = sum(sqr(X)); 
    nd = 0.0;
    for(int nc=0; nc<ncmps; ++nc) 
      for(int j=0; j<J; ++j) 
        nd(j) += sum(sqr(Y[j][nc]));

    cout << "signal norm = " << sqrt(n1) << endl <<
      "WT norm = " << sqrt(na+sum(nd)) << endl;

    TinyVector<bool, dim> szodd = Xcopy.extent()%2==1;
    wav.ilwt<dim>(X, Y, szodd);
    //cout << "Reconstruct X = " << X << endl;
    if(sqrt(sum(sqr(X-Xcopy))) >= 1e-6 ) {
      cerr << "sqrt(sum(sqr(X-Xcopy))) = " << sqrt(sum(sqr(X-Xcopy)));
      throw std::range_error("Imperfect reconstruction");
    }
    if(sqrt(fabs(n1-na-sum(nd)))/X.size() >= 1e-4) {
      cerr << "sqrt(fabs(n1-na-sum(nd)))/X.size() = " << 
        sqrt(fabs(n1-na-sum(nd)))/X.size();
      throw std::range_error("Different L2 norm");
    }
  }
  cout << "Average time: " << dt/REP;
}


/*void test_extend_shrink() {

  const int len = 5, pad = 4;
  Array<int, 2> X(len,len);
  TinyVector<extModeEnum, 2> em;

  X = (1 +  tensor::i) * (1 + tensor::j);
  cout << "Original " << X << endl;

  em = zpd;
  extend_center(X, TinyVector<int, 2>(len+pad, len+pad), em);
  cout << "zpd(2) " << X << endl;

  shrink_center(X, TinyVector<int, 2>(len, len));
  cout << "Shrink to original " << X << endl;

  em = periodic;
  extend_center(X, TinyVector<int, 2>(len+pad, len+pad), em);
  cout << "periodic(2) " << X << endl;
  }*/

void test_cascade()
{
  const size_t dim=1;
  LS<double> wav("coif1");
  LS<double>::extMode<dim>() = zpd;
  auto_ptr<pair<Array<double, dim>, Array<double, dim> > > wsf;
  wsf = wav.wsfun<dim>(3);
  cout << "Scaling Function" << endl << wsf->first << endl << "Wavelet" <<
    endl << wsf->second;
}

/*void test_init()
  {
  LS<float> wav("db2");
  wav.set_init(true);
  }*/

/*void test_wemd()
  {
  vector<Array<float, 1> > H(1);
  H[0].resize(8);
  H[0] = 0;
  H[0](2) = 1; H[0](5) = -1;
  cout << H[0] << endl;
  vector<map<unsigned, float> > wd;

  wemddes(H, wd, 1, (float)0, 0, "db2");

  cout << wd[0];
  }*/


int main(int argc, char * argv[])
{
  cout << "Test 1D Lifting wavelet transform with db2" << endl;
  test_lwt1();
  cout << endl << "Test 2D Lifting wavelet transform with coif2" << endl;
  test_lwt2();
  cout << endl << "Test 3D Lifting wavelet transform with sym2" << endl;
  test_lwt3();
  cout << endl << "Test the cascade algorithm (computes wavelet, scaling function) \
    for coif1"  << endl;
  test_cascade();
  cout << endl << "Success ! Press <enter> to exit ...";
  cin.get();
  return 0;
}
