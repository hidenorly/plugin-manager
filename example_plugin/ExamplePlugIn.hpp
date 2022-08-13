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

#ifndef __PLUGINMANAGER_TEST__
#include "PlugInManager.hpp"
#endif /* __PLUGINMANAGER_TEST__ */

class ExamplePlugInBase : public IPlugIn
{
public:
    ExamplePlugInBase(){};
    virtual ~ExamplePlugInBase(){};

    /* @desc initialize at loading the  plug-in shared object such as .so */
    virtual void onLoad(void){};
    /* @desc uninitialize at unloading the  plug-in shared object such as .so */
    virtual void onUnload(void){};
    /* @desc report your  plug-in's unique id
        @return unique plug-in id. may use uuid. */
    virtual std::string getId(void){return "nothing";};
    /* @desc report plugin type
     @return plug-in type. */
      virtual std::string getType(void){ return "ExamplePlugInBase"; };
    /* @desc this is expected to use by strategy
        @return new YourConcreteClass()'s instanciated result */
    virtual IPlugIn* newInstance(void) = 0;
    virtual std::string toString(void){ return "NoPlugIn"; };
    virtual void doSomething(void) = 0;
};

typedef TPlugInManager<ExamplePlugInBase> ExamplePlugInManager;
