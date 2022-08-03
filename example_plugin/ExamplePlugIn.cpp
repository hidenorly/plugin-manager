/*
  Copyright (C) 2022 hidenorly

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#include "ExamplePlugIn.hpp"
#include <string>
#include <iostream>
#include <algorithm>

class ConcreteExamplePlugIn;
class ConcreteExamplePlugIn : public ExamplePlugInBase
{
public:
  ConcreteExamplePlugIn(){
    std::cout << "ConcreteExamplePlugIn::constructor()" << std::endl;
  };
  virtual ~ConcreteExamplePlugIn(){
    std::cout << "ConcreteExamplePlugIn::destructor()" << std::endl;
  };
  virtual std::string toString(void){ return "ConcreteExamplePlugIn"; };

  /* @desc initialize at loading the filter plug-in shared object such as .so */
  virtual void onLoad(void){
    std::cout << "ConcreteExamplePlugIn::onLoad" << std::endl;
  }
  /* @desc uninitialize at unloading the filter plug-in shared object such as .so */
  virtual void onUnload(void){
    std::cout << "ConcreteExamplePlugIn::onUnload" << std::endl;
  }
  /* @desc report your filter plug-in's unique id
     @return unique plug-in id. may use uuid. */
  virtual std::string getId(void){
    return std::string("ConcreteExamplePlugIn");
  }
  /* @desc this is expected to use by strategy
     @return new YourFilter()'s result */
  virtual IPlugIn* newInstance(void){
  	std::cout << "ConcreteExamplePlugIn::newInstance" << std::endl;
    return new ConcreteExamplePlugIn();
  }

  virtual void doSomething(void){
    std::cout << "ConcreteExamplePlugIn::doSomething" << std::endl;
  };
};


extern "C"
{
__attribute__ ((visibility ("default"))) void* getPlugInInstance(void)
{
  ConcreteExamplePlugIn* pInstance = new ConcreteExamplePlugIn();
  return reinterpret_cast<void*>(dynamic_cast<IPlugIn*>(pInstance));
}
};
