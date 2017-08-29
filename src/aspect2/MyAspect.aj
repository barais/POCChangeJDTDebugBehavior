package aspect2;

public aspect MyAspect {
	 before() :execution(* org.eclipse.ui.PlatformUI.getWorkbench()){
	        System.err.println("Hello eclipse!");
	    }

}
