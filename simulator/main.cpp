#include "robot.hpp"
#include <iostream>
#include <iomanip>
#include <string>
#include <sstream>
int main(){
 Robot robot;std::string line;
 std::cout<<std::setprecision(7);
 std::cerr<<"Robot simulator: enter linear_m_s angular_rad_s per line; 'quit' to stop\n";
 while(std::getline(std::cin,line)){
  if(line=="quit")break;
  double linear,angular;std::istringstream input(line);
  if(!(input>>linear>>angular)){std::cout<<"{\"error\":\"Invalid command\"}"<<std::endl;continue;}
  for(int i=0;i<10;++i)robot.advance(linear,angular,.1);
  std::cout<<"{\"x\":"<<robot.x<<",\"y\":"<<robot.y<<",\"heading\":"<<robot.heading<<",\"linear\":"<<linear<<",\"angular\":"<<angular<<"}"<<std::endl;
 }
}