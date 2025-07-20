# plugin-manager

This is a plug-in framework, the plug-in example and the test case.

* How to use the framework: See the test case
* How to create the plug-in: See the example_plugin
* The others
  * See Makefile to create your own plug-in Makefile.

## Basic usage

1. Define your plug-in base class (common header between your plug-in developer and the plug-in user program)

```
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
```


2. Define the plug-in manager for your defined plug-in base class with template  (common header between your plug-in developer and the plug-in user program)

```
typedef TPlugInManager<ExamplePlugInBase> ExamplePlugInManager;
```


3. Define your concrete plug-in class. (plug-in developer own)

```
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

  /* @desc initialize at loading the  plug-in shared object such as .so */
  virtual void onLoad(void){
    std::cout << "ConcreteExamplePlugIn::onLoad" << std::endl;
  }
  /* @desc uninitialize at unloading the  plug-in shared object such as .so */
  virtual void onUnload(void){
    std::cout << "ConcreteExamplePlugIn::onUnload" << std::endl;
  }
  /* @desc report your plug-in's unique id
     @return unique plug-in id. may use uuid. */
  virtual std::string getId(void){
    return std::string("ConcreteExamplePlugIn");
  }
  /* @desc this is expected to use by strategy
     @return new YourPlugIn's result */
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
```

Note that you should implement ```virtual IPlugIn* newInstance(void)``` as the above (return your your class's instance with ```new YourClass()``` ).

And also you should implement ```getPlugInInstance``` as extern "C".



4. Use the plug-in with the plug-in manager (The plug-in user program)

```
  ExamplePlugInManager::setPlugInPath("lib/example-plugin");
  std::weak_ptr<ExamplePlugInManager> pWeakManager = ExamplePlugInManager::getManager();
  std::shared_ptr<ExamplePlugInManager> pManager = pWeakManager.lock();
  if( pManager ){
    pManager->initialize();

    std::vector<std::string> plugInIds = pManager->getPlugInIds();
    for(auto& aPlugInId : plugInIds){
      std::shared_ptr<ExamplePlugInBase> thePlugIn = ExamplePlugInManager::newInstanceById( aPlugInId );
      if( thePlugIn ){
        thePlugIn->doSomething(); // this is your plug-in's own method.
      }
    }
  }
```


5. Finish up  (At the end of your plug-in user program)

```
    pManager->terminate();
```
