package aspect2;

import java.util.ArrayList;
import java.util.List;

import org.aspectj.lang.JoinPoint;
import org.eclipse.jdi.internal.StackFrameImpl;
import org.eclipse.jdt.debug.core.IJavaStackFrame;
import org.eclipse.jdt.internal.debug.core.model.JDIStackFrame;

import com.sun.jdi.Field;
import com.sun.jdi.Method;
import com.sun.jdi.ObjectReference;
import com.sun.jdi.StackFrame;
import com.sun.jdi.ThreadReference;
import com.sun.jdi.Value;

public aspect MyAspect {
	before() :execution(* org.eclipse.ui.PlatformUI.getWorkbench()){
		System.err.println("Hello eclipse!");
	}

	private int tabCount = 0;

	pointcut AnyMethod() : /*(call(* *.*(..)) || execution(* *.*(..)))
	                        && !within(MyAspect) && !call(void java.lang.Object.wait(long))
	                        && !execution(void org.eclipse.jdi.internal.connect.PacketReceiveManager.waitForPacketAvailable(long, Object))
	    					&& !within(org.eclipse.jdi.internal.connect.PacketReceiveManager)
	    					&& !within(	    java.util.ListIterator)
	    					&& !within(com.sun.jdi.connect.spi.Connection)
	    					&& !within(org.eclipse.jdi.internal.connect.SocketConnection)
	    					&& !within(org.eclipse.jdi.internal.**)
	    					&& !within(org.eclipse.jdi.internal.jdwp.**)
	    					&& !call(boolean com.sun.jdi.connect.spi.Connection.isOpen())
	    					&& !execution(boolean org.eclipse.jdi.internal.connect.PacketManager.VMIsDisconnected())
	    					&& !call(JdwpCommandPacket org.eclipse.jdi.internal.event.EventQueueImpl.getCommandVM(int, long))
							&& !call(void org.eclipse.jdi.internal.event.EventQueueImpl.handledJdwpEventSet())
							&& !call(* org.eclipse.jdt.internal.debug.core.EventDispatcher.*(..))
							&&! call(JdwpCommandPacket org.eclipse.jdi.internal.event.EventQueueImpl.getCommandVM(int, long))
							&&! 		execution(EventSet org.eclipse.jdi.internal.event.EventQueueImpl.remove(long))
							&&! 	call(EventSet com.sun.jdi.event.EventQueue.remove(long))
							&&! 	execution(boolean org.eclipse.jdt.internal.debug.core.EventDispatcher.isShutdown())
							&&! 	execution(boolean org.eclipse.jdt.internal.debug.core.EventDispatcher.isShutdown())
							&&! 	call(EventSet com.sun.jdi.event.EventQueue.remove(long))
							&&! 		execution(EventSet org.eclipse.jdi.internal.event.EventQueueImpl.remove(long))
							&&! call(JdwpCommandPacket org.eclipse.jdi.internal.event.EventQueueImpl.getCommandVM(int, long))*/
	//						 call(* org.eclipse.jdt.internal.debug.core.model.JDIFieldVariable.*(..)) ||
							 call(* com.sun.jdi.ObjectReference.setValue(..));
	// call(protected void
	// org.eclipse.jdt.internal.debug.core.model.JDIFieldVariable.setJDIValue(..));

	void around(): AnyMethod()
	    {
		Method m1 = null;
		@SuppressWarnings("restriction")
		ObjectReference r = (ObjectReference) thisJoinPoint.getTarget();
		String fName = ((Field) thisJoinPoint.getArgs()[0]).name();
		String sName="";
		if (fName.length()>1) {
			sName= "set" + (fName.substring(0, 1)).toUpperCase() + fName.substring(1, fName.length());
		}else {
			sName = "set" + fName.toUpperCase();
		}
		for (Method m : r.referenceType().allMethods()) {
			if (m.name().equals(sName)) {
				m1 = m;
			}
		}
		List<Value> l = new ArrayList<Value>();
		l.add((Value) thisJoinPoint.getArgs()[1]);
		ThreadReference tref = null;
		try {
			for (ThreadReference tr : r.virtualMachine().allThreads()) {
				System.err.println(tr.name());
				if (tr.name().equals("main")) {
					tref = tr;
				}
			}
			System.err.println(			tref.frameCount());
			
			

			if (m1 != null) {
				r.invokeMethod(tref, m1, l, 0);//r.entryCount());
			}
			
			for(StackFrame frame : tref.frames()) {
				System.err.println(frame.getClass());
				org.eclipse.jdi.internal.StackFrameImpl impl = (StackFrameImpl) frame;
			}

			
			System.err.println(			tref.frameCount());
			
		} catch (Exception e) {
			e.printStackTrace();
		}

		
		//System.out.println("Caller: " + thisEnclosingJoinPointStaticPart.getSignature().toShortString());
		//PrintMethod(thisJoinPointStaticPart);
		
		tabCount++;
		return;
	}

	after() : AnyMethod()
	    {
		tabCount--;

	}

	private void PrintMethod(JoinPoint.StaticPart inPart) {
		System.err.println(GetTabs() + inPart);
	}

	private String GetTabs() {
		String tabs = "";
		for (int i = 0; i < tabCount; i++) {
			tabs += "\t";
		}
		return tabs;
	}
}
