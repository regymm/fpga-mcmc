#include <iostream>
#include <pthread.h>
#include <cmath>
#include <random>
#include <ctime>
#include <algorithm>
#include <cstring>
#include <immintrin.h>
#include <xmmintrin.h>
#include "omp.h"

using namespace std;

#define SQR(x) ((x)*(x))

double mass = 1.;
double hb = 1.;
double omega = 1.;

//default_random_engine  seed;
//uniform_real_distribution<double> ran1(-1., 1.);
//uniform_real_distribution<double> ran2(0., 1.);
int g_seed;
//double ran1(int, int);
//double ran2(int, int);

float* arr;
float* arr0;
float* arr1;
float* arr2;
float* arr3;
float* arr4;
float* arr5;
float* arr6;
float* arr7;

class Path {
public:
    Path() {
        this->x = nullptr;
    }
    Path(int N, double a, double x0) {
//        mchain.Corr();
//        cout << "Correlation calculated." << endl;
        this->x = new double[N];
        // With periodic bound condition
        this->x[0] = x0;
        // Bad performance
//        for(int i = 1; i < N; i++)
//            this->x[i] = 0;
        this->a = a;
        this->N = N;
    };
    ~Path() {
        delete [] this->x;
        this->x = nullptr;
    }
    // just use void... so a=b=c is not availiable
    void operator=(const Path& src) {
        // self-assign?
        if(this == &src)
            return;
        delete [] this->x;
        this->N = src.N;
        this->a = src.a;
        this->x = new double[N];
        memcpy(this->x, src.x, N * sizeof(double));
//        for(int i = 0; i < N; i++) this->x[i] = src.x[i];
    }
    double CalcAction();
    double xsqr() {
        double t = 0;
        for(int i = 0; i < N; i++)
            t += SQR(x[i]);
        t += SQR(x[0]);
        t /= N + 1;
//        cout << "xsqr: " << t << endl;
        return t;
    }
    // totally N+1 points, from 0 to N.
    int N;
    // Lattice spacing a
    double a;
    // a*N means total simulation time
    // x_i: x0 to xN, x_0 is the initial position
    double* x;
};

double Path::CalcAction()
{
    double action = 0;
    for(int i = 0; i < N - 1; i++) {
        action += SQR(x[i + 1] - x[i])/ (2 * a * omega) + 0.25 * a * omega * (SQR(x[i + 1]) + SQR(x[i]));
    }
    // periodic bound condition
    action += SQR(x[N - 1] - x[0])/ (2 * a * omega) + 0.25 * a * omega * (SQR(x[N - 1]) + SQR(x[0]));
    action *= hb;
    return action;
}

class MChain {
public:
    MChain() {
        this->chain = nullptr;
    }
    MChain(double delta, int Nconf, int Ndump, int Nskip, const Path& initi) {
        this->delta = delta;
        this->Nconf = Nconf;
        this->Ndump = Ndump;
        this->Nskip = Nskip;
        this->chain = new Path[Nconf];
        this->chain[0] = initi;
        // and use a and N in initi as Path config
        this->path_N = initi.N;
        this->path_a = initi.a;
        // initialize random sequenct generator
        for(int i = 0; i < path_N; i++) t_iter.push_back(i);
    }
    ~MChain() {
        delete [] chain;
        chain = nullptr;
    }
    // let the Chain process!
    void Run();
    void Run2();
    void Result();
    void Corr();
//    static double Weight(const Path& x2, const Path& x1, int pos);
    // position change step size
    double delta;
    // total configurations
    int Nconf;
    // initial dump configurations
    int Ndump;
    // skipped number of conf.s in measurements
    int Nskip;
    int path_N;
    double path_a;
    // An array of pathes in the Markov Chain
    Path* chain;
    vector<int> t_iter;
};

inline unsigned int xor128(void) {
    static unsigned int x = g_seed;
    static unsigned int y = 362436069;
    static unsigned int z = 521288629;
    static unsigned int w = 88675123;
    unsigned int t;
    t = x ^ (x << 11);
    x = y; y = z; z = w;
    return w = (w ^ (w >> 19) ^ (t ^ (t >> 8))) & 0x7FFFFFFF;
}

inline double ranm1p1()
{
    return ((double)(xor128() << 2)) / 0x7FFFFFFF - 1;
    //return ((double)rand() / RAND_MAX) * 2 - 1;
}
inline double ran0p1()
{
    return (double)xor128() / 0x7FFFFFFF;
    //return (double)rand() / RAND_MAX;
}

//double ranrange(double min, double max)
//{
//    return (rand() * 1.0  / 0x7FFFFFFF) * (max - min) + min;
//}

inline double p1(double x00, double x01, double x02, double a)
{
    return SQR(x01 - x00) / (2 * a) + .25 * a * (SQR(x00) + SQR(x01)) + \
    SQR(x02 - x01) / (2 * a)  + .25 * a * (SQR(x02) + SQR(x01));
}

inline double ee(double a2, double a1)
{
    return exp(-(a2 - a1));
}

inline double Weight(double a, double x00, double x01, double x02, double x10, double x11, double x12)
{
    double a1 = p1(x00, x01, x02, a);
    double a2 = p1(x10, x11, x12, a);
    return ee(a2, a1);
}

// With optimization and SIMD
void MChain::Run2() {
    // calculate the time-consuming operations only once
    double path_a_rev = 1. / path_a;
    __m256 _a = _mm256_set1_ps(path_a);
    __m256 _a_rev = _mm256_set1_ps(path_a_rev);
    __m256 _delta = _mm256_set1_ps(delta);
    __m256 _a_expres = _mm256_add_ps(.5 * _a, _a_rev);
    // Generate a random seq of 1 to N
    for(int i = 0; i < Nconf - 1; i++) {
//        cout << "--" << endl;
        chain[i + 1] = chain[i];
        // need to replaced by std::shuffle instead
        // If no need to reshuffle, then parallelism is ready
        for(int p = 0; p < 3; p++) {
            // path_N-1 here to avoid parallel error
            int j;
            // This loop can be parallelled
//#pragma omp parallel for num_threads(4)
            for(j = p; j < path_N - 1 - 3*8; j+=3*8) {
//                auto arr = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
//                auto arr0 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
//                auto arr1 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
//                auto arr2 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
                for (int bb = 0; bb < 8; bb++) {
                    int kk = j + bb * 3;
                    int posl = (kk == 0 ? path_N - 1 : kk - 1);
                    int posm = kk;
                    int posh = kk + 1;
                    arr[bb] = ranm1p1();
                    arr1[bb] = chain[i + 1].x[posm];
                    // minus here!
                    arr0[bb] = -chain[i + 1].x[posl];
                    arr2[bb] = -chain[i + 1].x[posh];
                }
                __m256 _ranm1p1 = _mm256_load_ps(arr);
//                _mm256_store_ps(arr7, _ranm1p1);
//                for(int bb = 0; bb < 4; bb++) {
//                    cout << arr[bb] << endl;
////                    cout << arr7[bb] << endl;
//                }
                __m256 _inc = _mm256_mul_ps(_delta, _ranm1p1);
                __m256 _x0 = _mm256_load_ps(arr0);
                __m256 _x1 = _mm256_load_ps(arr1);
                __m256 _x2 = _mm256_load_ps(arr2);
                __m256 _xs = _x1;
                _xs = _mm256_add_ps(_xs, _x1);
                // minus above, so directly add here
                _xs = _mm256_add_ps(_xs, _x0);
                _xs = _mm256_add_ps(_xs, _x2);
                __m256 p1 = _mm256_mul_ps(_a, _x1);
                __m256 p2 = _mm256_mul_ps(_a_rev, _xs);
                __m256 p3 = _mm256_mul_ps(_inc, _a_expres);
                __m256 _ans = _mm256_mul_ps(_inc, _mm256_add_ps(_mm256_add_ps(p1, p2), p3));
                _mm256_store_ps(arr1, _ans);
                _mm256_store_ps(arr2, _inc);
                for (int bb = 0; bb < 8; bb++) {
                    int kk = j + bb * 3;
//                    cout << exp(-arr3[bb]) << endl;
                    if (ran0p1() < exp(-arr1[bb]))
//                        cout << arr4[bb] << endl;
                        chain[i + 1].x[kk] += arr2[bb];
                }
//                delete [] arr;
//                delete [] arr0;
//                delete [] arr1;
//                delete [] arr2;
            }
            // deal with left data, this cannot be parallelled
            for(; j < path_N; j += 3) {
                int k = j;
                double inc = delta * ranm1p1();
                int posl = (k == 0 ? path_N-1 : k - 1);
                int posm = k;
                int posh = (k == path_N-1 ? 0 : k + 1);
                double x00 = chain[i + 1].x[posl];
                double x01 = chain[i + 1].x[posm];
                double x02 = chain[i + 1].x[posh];
                double path_a_rev = 1. / path_a;
                double xs = x01 + x01 - x00 - x02;
                if (ran0p1() < exp(-inc * ((.5 * path_a + path_a_rev) * inc + \
                    path_a * x01 + path_a_rev * xs))) chain[i + 1].x[k] += inc;
            }
        }
    }
}
// With optimization
void MChain::Run() {
    // Generate a random seq of 1 to N
    for(int i = 0; i < Nconf - 1; i++) {
        chain[i + 1] = chain[i];
        // need to replaced by std::shuffle instead
        // If no need to reshuffle, then parallelism is ready
//        random_shuffle(t_iter.begin(), t_iter.end());
            for(int j = 0; j < path_N; j+=1) {
//            int k = t_iter[j];
                int k = j;
                double inc = delta * ranm1p1();
                int posl = (k == 0 ? path_N-1 : k - 1);
                int posm = k;
                int posh = (k == path_N-1 ? 0 : k + 1);
                double x00 = chain[i + 1].x[posl];
                double x01 = chain[i + 1].x[posm];
                double x02 = chain[i + 1].x[posh];
                double path_a_rev = 1. / path_a;
                // this optim may have been done by compiler
                double xs = x01 + x01 - x00 - x02;
                // reading the asm code, their is 5 mul command, which is nearly optimum
//                cout <<  exp(-inc * ((.5 * path_a + path_a_rev) * inc + path_a * x01 + path_a_rev * xs)) << endl;
                if (ran0p1() < exp(-inc * ((.5 * path_a + path_a_rev) * inc + \
                path_a * x01 + path_a_rev * xs))) {
                    // accept
                    chain[i + 1].x[k] += inc;
//                    cout << inc << endl;
                }
                else {
                    // reject
                }
            }
    }
}
// Naive Calculation
//void MChain::Run() {
//    // Generate a random seq of 1 to N
//    for(int i = 0; i < Nconf - 1; i++) {
//        chain[i + 1] = chain[i];
//        // may cause double free if `Path temp=chain[i];`
//        Path temp;
//        temp = chain[i];
//        // need to replaced by std::shuffle instead
////        random_shuffle(t_iter.begin(), t_iter.end());
////        cout << "MChain Run " << i << endl;
//        for(int j = 0; j < path_N; j++) {
//            double inc = delta * ranm1p1();
//            chain[i + 1].x[j] += inc;
//            if (ran0p1() < Weight(chain[i + 1], temp, j)) {
//                // accept
//                // backup to temp
//                temp.x[j] += inc;
//            }
//            else {
//                // reject
//                // reverse change
//                chain[i + 1].x[j] -= inc;
//                // temp unchanged
//            }
//        }
//    }
//}

void MChain::Result(){
    double avg = 0;
    int Ncnt = (Nconf - Ndump) / Nskip;
//    cout << Ncnt << endl;
    for(int i = Ndump; i < Nconf; i += Nskip) {
        avg += chain[i].xsqr();
    }
    avg /= Ncnt;
    cout << "Expectation value " << avg << endl;
    double err = 0;
    for(int i = Ndump; i < Nconf; i += Nskip) {
	//err += SQR(chain[i].xsqr());
	err += SQR(chain[i].xsqr() - avg);
	//for(int j = 0; j < path_N; j++)
	    //err += SQR(SQR(chain[i].x[j]) - avg);
    }
    //err /= (Ncnt - 1) * Ncnt * path_N;
    err /= (Ncnt - 1) * Ncnt;
    //err /= Ncnt * path_N;
    err = sqrt(err);
    cout << "Err: " << err << endl;
    // serial calculation of Err
    double errs = 0;
    double avgs = 0;
    // the serial part
    for(int i = Ndump; i < Nconf; i += Nskip) {
        //for(int j = 0; j < path_N; j++) {
            //errs += SQR(SQR(chain[i].x[j]));
            //avgs += SQR(chain[i].x[j]);
        //}
	avgs += chain[i].xsqr();
	errs += SQR(chain[i].xsqr());
        //errs += SQR(SQR(chain[i].x[0]));
        //avgs += SQR(chain[i].x[0]);
    }
    // some final processing
    //avgs /= Ncnt * (path_N + 1);
    avgs /= Ncnt;
    // errs /= Ncnt * (Ncnt - 1) * (path_N + 1);
    //errs /= Ncnt * (path_N + 1);
    errs /= Ncnt;
    //errs = sqrt((errs - SQR(avgs)) / (Ncnt - 1));
    errs = sqrt((errs - SQR(avgs)) / (Ncnt - 1));
    cout << "Avgs: " << avgs << endl;
    cout << "Errs: " << errs << endl;
    cout << Ncnt << " " << path_N << endl;
}

void Randomize() {
//    seed.seed(time(nullptr));
    srand((unsigned)time(0));
    g_seed = (unsigned)time(0);
}

void Init_SSE() {
    arr = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr0 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr1 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr2 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr3 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr4 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr5 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr6 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
    arr7 = (float*) aligned_alloc(64, sizeof(float)*512 / (8 * sizeof(float)));
}
void Free_SSE() {
    delete [] arr;
    delete [] arr0;
    delete [] arr1;
    delete [] arr2;
    delete [] arr3;
    delete [] arr4;
    delete [] arr5;
    delete [] arr6;
    delete [] arr7;
}

void MChain::Corr()
{
    int tmax = 100;
    auto C = new double[tmax];
    int Ncnt = (Nconf - Ndump) / Nskip;
    for(int t = 0; t < tmax; t++) {
        double corr = 0;
        for(int m = Ndump; m < Nconf; m += Nskip) {
            double xx = 0.;
            for(int t0 = 0; t0 < path_N - tmax; t0++) {
                xx += chain[m].x[t0] * chain[m].x[t0 + t];

            }
            xx /= (path_N - tmax);
            corr += xx;
        }
        corr /= Ncnt;
        C[t] = corr;
        cout << C[t] << endl;
    }
    cout << "--" << endl;
    for(int t = 0; t < tmax; t++) {
        cout << log(fabs(C[t])) << endl;
    }
}

void AVX_Test()
{
    // AVX command test
    cout << "AVX test run..." << endl;
    __attribute__ ((aligned(16)))
    int n = 256 / (8 * sizeof(float));
    float* w = (float*) aligned_alloc(64, sizeof(float)*n);
    float* y = (float*) aligned_alloc(64, sizeof(float)*n);
    w[0] = .2;
    w[1] = .3;
    w[2] = .4;
    w[3] = .5;
    __m256 _x = _mm256_set1_ps(0.2);
    __m256 _w = _mm256_load_ps(w);
    __m256 _y = _mm256_mul_ps(_x, _w);
    _mm256_store_ps(y, _y);
    cout << y[0] << endl;
    cout << y[1] << endl;
    cout << y[2] << endl;
    cout << y[3] << endl;
    cout << "AVX test ok." << endl;
}

int main(int argc, char* argv[]) {

    clock_t clock_timer = clock();
    cout << "Program begin." << endl;
    Randomize();
    Init_SSE();
    // initialize a path, cold start
    //Path initi = Path(512, 0.125, 0);
    Path initi = Path(500, 0.1, 0);
    for(int i = 0; i < initi.N; i++) initi.x[i] = 0;
    cout << "Cold start initialized." << endl;
    // construct: delta, Nconf, Ndump, Nskip, start_path
    // 500M memory used in the default data scale 500, 0.2, 130000
    MChain mchain = MChain(0.2, 130000, 10000, 600, initi);
    //MChain mchain = MChain(0.1, 200000, 50000, 1, initi);
    //MChain mchain = MChain(0.125, 200000, 50000, 1, initi);
    if (argc == 2 && strcmp(argv[1], "SIMD") == 0) {
        cout << "Run with SIMD..." <<endl;
        mchain.Run2();
    }
    else {
        cout << "Run without SIMD...";
        mchain.Run();
    }
    cout << "Markov chain finished running." << endl;
    mchain.Result();
    cout << "Result generated." << endl;
    // mchain.Corr();
    // cout << "Correlation calculated." << endl;
    Free_SSE();
//    for(int i = 0; i < mchain.Nconf; i++) {
//        for(int j = 0; j < mchain.chain[0].N; j++) {
//            cout << mchain.chain[i].x[j] << endl;
//        }
//        cout << endl << endl;
//    }
    cout << "Program end." << endl;
    cout << "Time: " << (double) (clock() - clock_timer) / CLOCKS_PER_SEC << endl;
    return 0;
}
