ruleset tutorial {
	meta {
	     name "Lab 7 Tutorials"
	     author "Christopher Pitts"
	     description <<Lab 7 Tutorial>>
	     logging on
	     sharing on
	     use module v1_wrangler alias wrangler
	     provides show_children
	     provides subs
	}
	global {
	       show_children = function() {wrangler:children();}
	       subs = function() {
  	       	    subs = wrangler:subscriptions(null, "name_space", "Closet");
  		    subs{"subscriptions"}
	       }
	}
	rule createAChild {
  	     select when pico_systems child_requested
  	     pre {
		 random_name = "Test_Child_" + math:random(999);
    	     	 name = event:attr("name").defaultsTo(random_name);
  	     }
  	     {
		wrangler:createChild(name);
	     }
  	     always {
    	     	    log("create child names " + name);
  		    }
	}
	rule deleteAChild {
  	     select when pico_systems child_deletion_requested
  	     pre {
    	     	 name = event:attr("name").klog("got name: ");
  	     }
  	     if(not name.isnull()) then {
    	     	    wrangler:deleteChild(name)
  	     }
  	     fired {
    	     	   log "Deleted child named " + name;
  	     } else {
    	       log "No child named " + name;
  	     }
        }
	rule installRulesetInChild {
 	 select when pico_systems ruleset_install_requested
  	 pre {
    	     rid = event:attr("rid");
    	     pico_name = event:attr("name");
  	 }
  	 wrangler:installRulesets(rid) with
    	   name = pico_name
        }
	rule CreateFurnaceSystem {
	     select when pico_systems create_furnace_system
  	     {
		wrangler:createChild("Furnace");
		wrangler:createChild("TempSensor");
		wrangler:createChild("Thermostat");
		wranglet:installRulesets("b16x30") with
		  name = "Thermostat"
	     }	     
	}
}