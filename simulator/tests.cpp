#include "robot.hpp"
#include <cassert>
#include <cmath>
#include <iostream>
int main(){
 Robot r;r.advance(1,0,1);assert(std::abs(r.x-1)<1e-8);assert(std::abs(r.y)<1e-8);
 r.advance(0,3.141592653589793/2,1);r.advance(1,0,1);assert(r.y>.99);
 bool failed=false;try{r.advance(1,0,-1);}catch(...){failed=true;}assert(failed);
 std::cout<<"Robot tests passed\n";
}