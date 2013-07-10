%module luadchppbloom

%runtime %{

#include <adchpp/adchpp.h>

#include <adchpp/PluginManager.h>
#include <adchpp/Core.h>
#include <adchpp/Signal.h>
#include <adchpp/Entity.h>

using namespace adchpp;
using namespace std;

%}

%include "exception.i"
%import "lua.i"

%runtime %{
#include <memory> 
#include <plugins/Bloom/src/BloomManager.h>
#include <iostream>
%}

%{
	static adchpp::Core *getCurrentCore(lua_State *l) {
		lua_getglobal(l, "currentCore");
		void *core = lua_touserdata(l, lua_gettop(l));
		lua_pop(l, 1);
		return reinterpret_cast<Core*>(core);
	}

%}

%template(SignalE) Signal<void (Entity&)>;
%template(SignalTraitsE) SignalTraits<void (Entity&)>;

class BloomManager {
public:
	bool hasBloom(adchpp::Entity& c);
	int64_t getSearches() const;
	int64_t getTTHSearches() const;
	int64_t getStoppedSearches() const;
	typedef SignalTraits<void (Entity&)> SignalBloomReady;
	SignalBloomReady::Signal& signalBloomReady() { return signalBloomReady_; }
};

%extend BloomManager {
	bool hasTTH(adchpp::Entity& c,const std::string tth) {
		return self->hasTTH(c,TTHValue(tth));
	}
}

%template(TBloomManagerPtr) shared_ptr<BloomManager>;

%inline %{

namespace adchpp {
/* Get Bloom Manager */
shared_ptr<BloomManager> getBM(lua_State* l) {
	return (std::dynamic_pointer_cast<BloomManager>(getCurrentCore(l)->getPluginManager().getPlugin("BloomManager")));
}

}

%}
