#include "AntiShakePositionSolution.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

AntiShakePositionSolution::AntiShakePositionSolution()
{

}

struct pos AntiShakePositionSolution::positionCalcu(int AnchorN, int Dimention, pos* anchorPos,double* meas) {

    pos tagPOS = {0,0 };//set a initial pos as seed
    if(AnchorN<3)  return tagPOS;
    //initalize the pos calculation
    double** pary;
    double** Q;
    double** tempQ;
    double** R;
    double** QT_y;
    double** temperror;
    int i, j;

    pary = (double**)malloc(sizeof(double*) * AnchorN);
    Q = (double**)malloc(sizeof(double*) * AnchorN);
    tempQ= (double**)malloc(sizeof(double*) * AnchorN);
    R = (double**)malloc(sizeof(double*) * AnchorN);
    QT_y = (double**)malloc(sizeof(double*) * AnchorN);
    temperror= (double**)malloc(sizeof(double*) * AnchorN);
    //printf("Input the array:\n");
    for (i = 0;i < AnchorN;i++)
    {
        pary[i] = (double*)malloc(sizeof(double) * Dimention);
        Q[i] = (double*)malloc(sizeof(double) * AnchorN);
        tempQ[i] = (double*)malloc(sizeof(double) * AnchorN);
        R[i] = (double*)malloc(sizeof(double) * Dimention);
        QT_y[i]= (double*)malloc(sizeof(double) * 1);
        temperror[i] = (double*)malloc(sizeof(double) * 1);
        for (j = 0;j < Dimention;j++)
        {
            pary[i][j] = 0;
            R[i][j] = 0;
        }
        for (j = 0;j < AnchorN;j++)
        {
            Q[i][j] = 0;
            tempQ[i][j] = 0;
        }
        QT_y[i][0] = 0;
        temperror[i][0] = 0;
    }
    double* ErrorV= (double*)malloc(sizeof(double) * AnchorN);

    double xtemp=0;
    double ytemp = 0;

    for (int m = 0;m < AnchorN;m++) {
        xtemp = xtemp + (anchorPos + m)->x;
        ytemp = ytemp + (anchorPos + m)->y;
    }
    tagPOS.x = xtemp / AnchorN;
    tagPOS.y = ytemp / AnchorN;

    pos tagPOSdelta = { 0,0 };//deltaPOS;
    for (int iteration = 0;iteration < ITE_NUM;iteration++) {
        ErrorCal(tagPOS, anchorPos, AnchorN, meas, ErrorV);//
        for (int ii = 0;ii < AnchorN;ii++)
            temperror[ii][0] = -ErrorV[ii];
        //for (int i = 0;i < AnchorN;i++)
            //printf("%f ",ErrorV[i]);
        //printf("\n");
        for (int m = 0;m < AnchorN;m++) {
            pary[m][0] = tagPOS.x - (anchorPos + m)->x;
            pary[m][1] = tagPOS.y - (anchorPos + m)->y;
        }
        //printf("A matric is \n:");
        //DispMatric(pary,AnchorN,2);
        // 4*2=4*4 * 4*2;
        QRdecompose(AnchorN, Dimention, pary, Q, R);

        //printf("Q matric is \n:");
        //DispMatric(Q, AnchorN, AnchorN);
        //printf("R matric is :");
        //DispMatric(R, AnchorN, Dimention);


        //QT_y=Q'*[-out0;-out1;-out2;-out3];//4*1 = 4*4 *4*1
        //deltaPOS(2) = QT_y(2) / R(2, 2);
        //deltaPOS(1) = (QT_y(1) - R(1, 2) * deltaPOS(2)) / R(1, 1);
        MatricTranspose(AnchorN, AnchorN, Q, tempQ);
        matric_multiplier(AnchorN, 1, AnchorN, tempQ, temperror, QT_y);
        //DispMatric(tempQ, AnchorN, AnchorN);
        //DispMatric(QT_y, AnchorN, 1);
        tagPOSdelta.y = QT_y[1][0] / R[1][1];
        tagPOSdelta.x = (QT_y[0][0] - R[0][1] * tagPOSdelta.y )/ R[0][0];
        tagPOS.x = tagPOS.x + tagPOSdelta.x;
        tagPOS.y = tagPOS.y + tagPOSdelta.y;
        printf("iteration %d th:  x =%f,y=%f \n", iteration+1,tagPOS.x,tagPOS.y);

    }
    return tagPOS;
}
void AntiShakePositionSolution::DispMatric(double **ptr,int row,int column) {
    for (int i=0;i < row;i++) {
        for (int j=0;j < column;j++) {
            printf("%f   ",ptr[i][j]);
        }
        printf("\n");
    }

}
//A  4*2
//Q  4*4
//R  4*2
void AntiShakePositionSolution::QRdecompose(int Arow,int Acolum,double **A,double **Q,double**R) {

    //initialize Q and G
    double** G;
    double** tempR;
    double** tempQ;
    double** G_inverse;
    G = (double**)malloc(sizeof(double*) * Arow);
    tempQ = (double**)malloc(sizeof(double*) * Arow);
    tempR = (double**)malloc(sizeof(double*) * Arow);
    G_inverse = (double**)malloc(sizeof(double*) * Arow);

    //printf("Input the array:\n");
    for (int i = 0;i < Arow;i++)
    {
        G[i] = (double*)malloc(sizeof(double) * Arow);
        G_inverse[i]= (double*)malloc(sizeof(double) * Arow);
        tempQ[i] = (double*)malloc(sizeof(double) * Arow);
        tempR[i] = (double*)malloc(sizeof(double) * Arow);
        for (int j = 0;j < Arow;j++)
        {
            G[i][j] = 0;
            G_inverse[i][j] = 0;
            tempQ[i][j] = 0;
        }
        for (int j = 0;j < Acolum;j++) {
            tempR[i][j] = 0;
        }
    }
    //Q=eyes(anchor)  G=eyes(anchor)
    matric_eyes(Q, Arow);
    matric_eyes(G,Arow);

    //R=A
    for (int i = 0;i < Arow;i++)
        for (int j = 0;j < Acolum;j++) {
            R[i][j] = A[i][j];
        }
    double c;
    double s;
    for (int j = 1;j <=Acolum;j++) {
        for (int i = Arow;i >= j+1 ;i--) {
            matric_eyes(G, Arow);
            givenrotation(&c, &s, R[i - 2][j - 1], R[i - 1][j - 1]);
            G[i-2][i-2] = c;
            G[i-2][i-1] = -s;
            G[i-1][i-2] = s;
            G[i-1][i-1] = c;
            //printf("G \n");
            //DispMatric(G, 4, 4);
            MatricTranspose(Arow, Arow, G, G_inverse);
            //printf("G \n");
            //DispMatric(R, 4, 2);

            //R=G'*R;
            matric_multiplier(Arow, Acolum, Arow, G_inverse, R, tempR);
            //printf("G inverse \n");
            //DispMatric(G_inverse, 4, 4);
            matric_copy(R,tempR,Arow,Acolum);
            //printf("R updated: \n");
            //DispMatric(R, 4,2);

            //Q=Q*G
            matric_multiplier(Arow, Arow, Arow,Q, G, tempQ);
            matric_copy(Q, tempQ, Arow, Arow);
            //printf("Q \n");
            //DispMatric(Q, 4, 4);
        }
    }

}

void AntiShakePositionSolution::givenrotation(double *c,double *s,double a,double b) {
    double r = 0;
    if (b == 0) {
        *c = 1;
        *s = 0;
    }
    else {
        if (fabs(b) > fabs(a)) {
            r = a / b;
            *s = 1 / sqrtSD(1 + r * r);
            *c = (*s) * r;
        }
        else {
            r = b / a;
            *c= 1 / sqrtSD(1 + r * r);
            *s = (*c) * r;
        }

    }
}

double AntiShakePositionSolution::sqrtSD(double n) {
#define PRECISION 0.0002
    double k = n;
    while (1) {
        if ((k * k > n - PRECISION)&&(k * k < n + PRECISION)) {
            break;
        }
        k = 0.5 * (k + n / k);
    }
    return k;
}
void AntiShakePositionSolution::ErrorCal(struct pos PosV, struct pos* anchor, int anchorN, double* meas, double* Error ){


for (int i = 0;i < anchorN;i++) {
    Error[i] = pow(PosV.x - (anchor+i)->x, 2.0) + pow(PosV.y - (anchor+i)->y, 2.0) - pow(meas[i], 2.0);
    Error[i] = Error[i] / 2.0;
}

}

// a is a M*N matric and b is a N*L matric
// will output M*L matric
void AntiShakePositionSolution::matric_multiplier(int M ,int L,int N,double **a,double **b,double **c) {
    for (int i = 0; i < M; i++)
    {
        for (int j = 0; j < L; j++)
        {
            c[i][j] = 0;
            for (int k = 0; k < N; k++)
                c[i][j] += a[i][k] * b[k][j];
            //printf("%lf\t", c[i][j]);
        }
        //printf("\n");
    }
}
void AntiShakePositionSolution::MatricTranspose(int R,int C,double** input,double** output) {
    for(int i=0;i<R;i++)
        for (int j = 0;j < C;j++) {
            output[j][i] = input[i][j];
        }
}
void AntiShakePositionSolution::matric_eyes(double** matric,int row_column) {
    for (int i = 0;i < row_column;i++)
        for (int j = 0;j < row_column;j++) {
            if (i == j) {
                matric[i][j] = 1;
                //G[i][j] = 1;
            }
            else {
                matric[i][j] = 0;
                //G[i][j] = 1;
            }
        }
}
void AntiShakePositionSolution::matric_copy(double **output,double**input,int R,int C) {
    for (int i = 0;i < R;i++)
        for (int j = 0;j < C;j++)
            output[i][j] = input[i][j];
}
