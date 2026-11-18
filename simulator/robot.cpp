#include "robot.hpp"
#include <cmath>
#include <algorithm>
#include <stdexcept>
void Robot::advance(double linear,double angular,double dt){
 if(!std::isfinite(linear)||!std::isfinite(angular)||!std::isfinite(dt)||dt<=0)throw std::invalid_argument("Invalid motion command");
 linear=std::clamp(linear,-2.0,2.0);angular=std::clamp(angular,-3.0,3.0);
 double mid=heading+.5*angular*dt;
 x+=linear*std::cos(mid)*dt;y+=linear*std::sin(mid)*dt;heading+=angular*dt;
 heading=std::remainder(heading,2*3.141592653589793);
}
