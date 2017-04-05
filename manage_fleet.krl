ruleset manage_fleet {
	meta {
	     name "Lab 7 manage_fleet Ruleset"
	     description <<CS 462 Lab 7>>
	     author "Christopher Pitts"
	     logging on
	     sharing on
	     use module v1_wrangler alias wrangler
	     provides show_children
	}
	global {
	       show_children = function(){wrangler:children();}
	}
	rule create_a_child {
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
	rule delete_a_child {
	     select when pico_systems child_deletion_requested
	     pre {
	     	 name = event:attr("name");
	     }
	     if (not name.isnull()) then {
	     	wrangler:deleteChild(name);
	     }
	     fired {
	     	   log "Deleted child name " + name;
	     }
	     else {
	     	  log "No child named " + name;
	     }
	}
}