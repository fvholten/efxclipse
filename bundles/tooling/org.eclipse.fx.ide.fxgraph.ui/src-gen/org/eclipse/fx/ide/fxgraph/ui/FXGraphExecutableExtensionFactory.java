/*
 * generated by Xtext
 */
package org.eclipse.fx.ide.fxgraph.ui;

import org.eclipse.fx.ide.fxgraph.ui.internal.FXGraphActivator;
import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;

import com.google.inject.Injector;


/**
 * This class was generated. Customizations should only happen in a newly
 * introduced subclass. 
 */
public class FXGraphExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return FXGraphActivator.getInstance().getBundle();
	}
	
	@Override
	protected Injector getInjector() {
		return FXGraphActivator.getInstance().getInjector(FXGraphActivator.AT_BESTSOLUTION_EFXCLIPSE_TOOLING_FXGRAPH_FXGRAPH);
	}
	
}
