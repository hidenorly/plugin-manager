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

#include "TestCase_System.hpp"
#include "PlugInManager.hpp"

TestCase_System::TestCase_System()
{
}

TestCase_System::~TestCase_System()
{
}

void TestCase_System::SetUp()
{
}

void TestCase_System::TearDown()
{
}

TEST_F(TestCase_System, testPlugInManager)
{
  IPlugInManager* pPlugInManager = new IPlugInManager();
  pPlugInManager->initialize();

  std::vector<std::string> plugInIds = pPlugInManager->getPlugInIds();
  for(auto& aPlugInId : plugInIds){
    EXPECT_TRUE( pPlugInManager->hasPlugIn( aPlugInId ) );
    EXPECT_NE( nullptr, pPlugInManager->getPlugIn( aPlugInId ) );
  }
  pPlugInManager->dump();

  EXPECT_FALSE( pPlugInManager->hasPlugIn( "hogehogehoge" ) );

  pPlugInManager->terminate();
}


TEST_F(TestCase_System, testOwnPlugInManager)
{
  class MyPlugIn : public IPlugIn
  {
  public:
    MyPlugIn(){};
    virtual ~MyPlugIn(){};

    virtual void onLoad(void){};
    virtual void onUnload(void){};
    virtual std::string getId(void){return "";};
    virtual std::string toString(void){ return "MyPlugIn"; };
  };

  typedef TPlugInManager<MyPlugIn> MyPlugInManager;


  MyPlugInManager::setPlugInPath("lib/my-plugin");
  std::weak_ptr<MyPlugInManager> pWeakManager = MyPlugInManager::getManager();
  std::shared_ptr<MyPlugInManager> pManager = pWeakManager.lock();
  if( pManager ){
    pManager->initialize();

    std::vector<std::string> plugInIds = pManager->getPlugInIds();
    for(auto& aPlugInId : plugInIds){
      EXPECT_TRUE( pManager->hasPlugIn( aPlugInId ) );
      EXPECT_TRUE( nullptr != pManager->getPlugIn( aPlugInId ) );
      std::cout << "MyPlugInManager::newInstanceById()" << std::endl;
      std::shared_ptr<MyPlugIn> pPlugIn = MyPlugInManager::newInstanceById( aPlugInId );
      EXPECT_TRUE( nullptr != pPlugIn );
    }
    pManager->dump();

    EXPECT_TRUE( MyPlugInManager::newInstanceById( "hogehogehoge" ) == nullptr );

    pManager->terminate();
  }
}
