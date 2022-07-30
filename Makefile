# compiler env.
UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
	CXX=ccache clang++
	LDLIBS=-ldl
	SHARED_CXXFLAGS= -fPIC -shared
endif
ifeq ($(UNAME),Darwin)
	CXX=ccache clang++
	LDLIBS=-stdlib=libc++
	SHARED_CXXFLAGS= -flat_namespace -dynamiclib
endif

CXXFLAGS=-std=c++2a -MMD -MP -Wall
LDFLAGS=-pthread

# project config
SRC_DIR ?= ./src
INC_DIR=./include
TEST_DIR=./test
LIB_DIR=./lib
BIN_DIR=./bin
OBJ_DIR=./out

# --- source code config --------------
INCS = $(wildcard $(INC_DIR)/*.hpp)

PLUGINMGR_SRCS = $(wildcard $(SRC_DIR)/*.cpp)
TEST_SRCS = $(wildcard $(TEST_DIR)/*.cpp)
INTEG_SRCS = $(PLUGINMGR_SRCS) $(TEST_SRCS)

# --- the object files config --------------
PLUGINMGR_OBJS = $(addprefix $(OBJ_DIR)/, $(notdir $(PLUGINMGR_SRCS:.cpp=.o)))
TEST_OBJS = $(addprefix $(OBJ_DIR)/, $(notdir $(TEST_SRCS:.cpp=.o)))
INTEG_OBJS = $(addprefix $(OBJ_DIR)/, $(notdir $(INTEG_SRCS:.cpp=.o)))

# --- build gtest (integrated) --------
INTEG_TARGET = $(BIN_DIR)/PLUGINMGR_test
INTEG_DEPS = $(INTEG_OBJS:.o=.d)

default: $(INTEG_TARGET)
.PHONY: default

#$(INTEG_TARGET): $(INTEG_SRCS)
#	@[ -d $(BIN_DIR) ] || mkdir -p $(BIN_DIR)
#	$(CXX) $(CXXFLAGS) -I$(INC_DIR) $(LDLIBS) -o $@ $^ -lgtest_main -lgtest

$(INTEG_TARGET): $(INTEG_OBJS)
	@[ -d $(BIN_DIR) ] || mkdir -p $(BIN_DIR)
	$(CXX) $(LDFLAGS) $(INTEG_OBJS) -o $@ $(LDLIBS) -lgtest_main -lgtest

$(PLUGINMGR_OBJS): $(PLUGINMGR_SRCS)
	@[ -d $(OBJ_DIR) ] || mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -I $(INC_DIR) -c src/$(notdir $(@:.o=.cpp)) -o $@

$(TEST_OBJS): $(TEST_SRCS)
	@[ -d $(OBJ_DIR) ] || mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -I $(INC_DIR) -c test/$(notdir $(@:.o=.cpp)) -o $@


-include $(INTEG_DEPS)


# --- Build for PLUGINMGR(shared) ------------
UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
	PLUGINMGR_SO_TARGET = $(LIB_DIR)/libpluginmanager.so
endif
ifeq ($(UNAME),Darwin)
	PLUGINMGR_SO_TARGET = $(LIB_DIR)/libpluginmanager.dylib
endif

pluginmanagershared: $(PLUGINMGR_SO_TARGET)
.PHONY: pluginmanagershared

$(PLUGINMGR_SO_TARGET): $(PLUGINMGR_OBJS)
	@[ -d $(LIB_DIR) ] || mkdir -p $(LIB_DIR)
	$(CXX) $(LDFLAGS) $(PLUGINMGR_OBJS) $(SHARED_CXXFLAGS) -o $@ $(LDLIBS)


# --- Build for PLUGINMGR(static) -------------------
PLUGINMGR_TARGET = $(LIB_DIR)/libpluginmgr.a
PLUGINMGR_DEPS = $(PLUGINMGR_OBJS:.o=.d)

pluginmgr: $(PLUGINMGR_TARGET)
.PHONY: pluginmgr
CXXFLAGS+= -fPIC #-flto=full

$(PLUGINMGR_TARGET): $(PLUGINMGR_OBJS)
	@[ -d $(LIB_DIR) ] || mkdir -p $(LIB_DIR)
	ar rs $(PLUGINMGR_TARGET) $(PLUGINMGR_OBJS)
	ranlib -c $(PLUGINMGR_TARGET)
#	$(AR) rvs $(PLUGINMGR_TARGET) $(PLUGINMGR_OBJS)
#	ranlib -c $@

-include $(PLUGINMGR_DEPS)

# --- Build for test cases w/libpluginmgr.a ---
TEST_TARGET = $(BIN_DIR)/test_with_pluginmgrlib
TEST_LDLIBS = $(LDLIBS) -L$(LIB_DIR)
TEST_LIBS = $(PLUGINMGR_TARGET)

test: $(TEST_TARGET)
.PHONY: test

$(TEST_TARGET): $(TEST_OBJS)
	@[ -d $(BIN_DIR) ] || mkdir -p $(BIN_DIR)
	$(CXX) $(LDFLAGS) $(TEST_LDLIBS) $(TEST_OBJS) $(TEST_LIBS) -o $@ -lgtest_main -lgtest



# --- Build for plug-in example(shared) ------------
EXP_DIR=./example_plugin
EXP_SRCS = $(wildcard $(EXP_DIR)/*.cpp)
LIB_EXP_DIR=$(LIB_DIR)/example-plugin
EXP_OBJS = $(addprefix $(OBJ_DIR)/, $(notdir $(EXP_SRCS:.cpp=.o)))

UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
	EXP_SO_TARGET = $(LIB_EXP_DIR)/libplugin_example.so
endif
ifeq ($(UNAME),Darwin)
	EXP_SO_TARGET = $(LIB_EXP_DIR)/libplugin_example.dylib
endif
EXP_DEPS = $(EXP_OBJS:.o=.d)

pluginexample: $(EXP_SO_TARGET)
.PHONY: pluginexample

$(EXP_SO_TARGET): $(EXP_OBJS)
	@[ -d $(LIB_DIR) ] || mkdir -p $(LIB_DIR)
	@[ -d $(LIB_EXP_DIR) ] || mkdir -p $(LIB_EXP_DIR)
	$(CXX) $(LDFLAGS) $(EXP_OBJS) $(SHARED_CXXFLAGS) -o $@ $(LDLIBS) $(PLUGINMGR_SO_TARGET)

$(EXP_OBJS): $(EXP_SRCS)
	@[ -d $(OBJ_DIR) ] || mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -I $(INC_DIR) -c $(EXP_DIR)/$(notdir $(@:.o=.cpp)) -o $@

-include $(EXP_DEPS)



.PHONY: all
all: $(PLUGINMGR_TARGET) $(PLUGINMGR_SO_TARGET) $(TEST_TARGET) $(EXP_SO_TARGET)

# --- clean up ------------------------
clean:
	rm -f $(TARGET) $(TEST_TARGET) $(INTEG_TARGET) $(OBJS) $(PLUGINMGR_OBJS) $(PLUGINMGR_DEPS) $(PLUGINMGR_SO_OBJS) $(PLUGINMGR_SO_DEPS)$(TEST_OBJS) $(INTEG_OBJS) $(INTEG_DEPS) $(EXP_OBJS) $(EXP_DEPS)
