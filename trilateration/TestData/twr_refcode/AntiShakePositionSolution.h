#ifndef ANTISHAKEPOSITIONSOLUTION_H
#define ANTISHAKEPOSITIONSOLUTION_H


struct pos {
    double x;
    double y;

    const pos& operator= (const pos& other){
        x = other.x;  y = other.y;
        return *this;
    }
};

class AntiShakePositionSolution
{
public:
    AntiShakePositionSolution();
#define ITE_NUM 4
void givenrotation(double* c, double* s, double a, double b);
double sqrtSD(double n);
struct pos positionCalcu(int AnchorN, int Dimention, pos* anchorPos, double* meas);
void ErrorCal(struct pos PosV, struct pos* anchor, int anchorN, double* meas, double* Error);
void DispMatric(double** ptr, int row, int column);
void matric_eyes(double** matric, int row_column);
void matric_copy(double** output, double** input, int R, int C);
void matric_multiplier(int M, int L, int N, double** a, double** b, double** c);
void QRdecompose(int Arow, int Acolum, double** A, double** Q, double** R);
void MatricTranspose(int R, int C, double** input, double** output);


};

#endif // ANTISHAKEPOSITIONSOLUTION_H
