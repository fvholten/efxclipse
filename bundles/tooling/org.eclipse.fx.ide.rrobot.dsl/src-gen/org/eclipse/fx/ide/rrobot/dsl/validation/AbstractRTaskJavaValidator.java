/*
 * generated by Xtext
 */
package org.eclipse.fx.ide.rrobot.dsl.validation;
 
import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EPackage;

public class AbstractRTaskJavaValidator extends org.eclipse.xtext.validation.AbstractDeclarativeValidator {

	@Override
	protected List<EPackage> getEPackages() {
	    List<EPackage> result = new ArrayList<EPackage>();
	    result.add(EPackage.Registry.INSTANCE.getEPackage("http://www.efxclipse.org/rrobot/task/1.0"));
	    result.add(EPackage.Registry.INSTANCE.getEPackage("http://www.efxclipse.org/rrobot/task/bundle/1.0"));
		return result;
	}

}
