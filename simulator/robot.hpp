#pragma once
struct Robot {
 double x=0,y=0,heading=0;
 void advance(double linear,double angular,double dt);
};
