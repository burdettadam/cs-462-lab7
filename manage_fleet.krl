ruleset manage_fleet {
	meta {
	     name "Lab 7 manage_fleet Ruleset"
	     description <<CS 462 Lab 7>>
	     author "Christopher Pitts"
	     logging on
	     sharing on
	     use module v1_wrangler alias wrangler
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
}