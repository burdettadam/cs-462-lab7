ruleset tutorial {
	meta {
	     name "Lab 7 Tutorials"
	     author "Christopher Pitts"
	     description <<Lab 7 Tutorial>>
	     logging on
	     sharing on
	     use module v1_wrangler alias wrangler
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
}