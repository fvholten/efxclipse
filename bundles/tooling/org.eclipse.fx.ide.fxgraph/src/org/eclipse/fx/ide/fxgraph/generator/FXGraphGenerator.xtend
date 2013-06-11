/*******************************************************************************
 * Copyright (c) 2012 BestSolution.at and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl<tom.schindl@bestsolution.at> - initial API and implementation
 *******************************************************************************/
package org.eclipse.fx.ide.fxgraph.generator

import org.eclipse.fx.ide.fxgraph.fXGraph.BindValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.ComponentDefinition
import org.eclipse.fx.ide.fxgraph.fXGraph.ControllerHandledValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.CopyValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.Element
import org.eclipse.fx.ide.fxgraph.fXGraph.IncludeValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.ListValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.LocationValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.MapValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.Model
import org.eclipse.fx.ide.fxgraph.fXGraph.Property
import org.eclipse.fx.ide.fxgraph.fXGraph.ReferenceValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.ResourceValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.ScriptHandlerHandledValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.ScriptValueExpression
import org.eclipse.fx.ide.fxgraph.fXGraph.ScriptValueReference
import org.eclipse.fx.ide.fxgraph.fXGraph.SimpleValueProperty
import java.util.List
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.xbase.compiler.ImportManager
import org.eclipse.fx.ide.fxgraph.fXGraph.ValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.ReferenceType
import org.eclipse.fx.ide.fxgraph.fXGraph.StaticCallValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.StaticValueProperty
import org.eclipse.fx.ide.fxgraph.fXGraph.ConstValueProperty

class FXGraphGenerator implements IGenerator {
	 
	def calculateRelativePath(Resource resource) {
		
			if( resource.URI.platformResource ) {
				var uri = resource.URI;
				var root = ResourcesPlugin::workspace.root;
				var project = root.getProject(uri.segment(1));
				var projectRelativePath = "";
				
//				var i = 2;
//				while( i < uri.segmentCount ) {
//					projectRelativePath = projectRelativePath + "/" + uri.segment(i);
//					i = i + 1;
//				}
//				
				var i = 0;
			
//				var jproject = JavaCore::create(project);
				
				for( seg : uri.segments ) {
					if( i >= 1 ) {
						projectRelativePath = projectRelativePath + "/" + uri.segment(i);
					}
					i = i + 1;
				}
			
				projectRelativePath = "../" + projectRelativePath.substring(project.name.length+2);
//				System::err.println("PRE-PATH: " + projectRelativePath);
				// projectRelativePath = projectRelativePath
//				var inSourceFound = false;
//			
//				for( packroot: jproject.rawClasspath ) {
//					if( packroot.entryKind == IClasspathEntry::CPE_SOURCE ) {
//						if( projectRelativePath.startsWith(packroot.path.toString) ) {
//							projectRelativePath = projectRelativePath.substring(packroot.path.toString.length);
//							inSourceFound = true;
//						}
//					}
//				}
//				
//				System::err.println("POST-PATH: " + projectRelativePath);
//				
//				if( inSourceFound ) {
					return projectRelativePath;
//				}
				
//				return null;		
			} else {
				return null;
			}
		
	}
	
	def doGeneratePreview(Resource resource, boolean skipController, boolean skipIncludes) {
		try {
			val projectRelativePath = calculateRelativePath(resource);
			if( projectRelativePath != null ) {
				return createContent(resource, projectRelativePath,true,skipController,skipIncludes).toString;
			}	
		} catch(Exception e) {
			
		}
		
		return null;
	}
		
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		try {
			val projectRelativePath = calculateRelativePath(resource);
		
			if( projectRelativePath != null ) {
				val relativeOutPath = projectRelativePath.replaceFirst(".fxgraph$",".fxml");
				fsa.generateFile(relativeOutPath, createContent(resource, projectRelativePath,false, false,false));
			}	
		} catch(Exception e) {
			
		}
		
	}
	
	
	def createContent(Resource resource, String projectRelativePath, boolean preview, boolean skipController, boolean skipIncludes) '''
		«val importManager = new ImportManager(true)»
		«val languageManager = new LanguageManager()»
		<?xml version="1.0" encoding="UTF-8"?>
		<!-- 
			Do not edit this file it is generated by e(fx)clipse from «projectRelativePath»
		-->
		
		«FOR rootElement : resource.contents.get(0).eContents.filter(typeof(ComponentDefinition))»
		«val body = componentDefinition(rootElement, importManager, languageManager, preview, skipController, skipIncludes)»
		<?import java.lang.*?>
		«FOR i:importManager.imports»
			<?import «i»?>
		«ENDFOR»
		«FOR i:languageManager.languages»
			<?language «i»?>
		«ENDFOR»
		«IF (resource.contents.get(0) as Model).componentDef.previewResourceBundle != null»
		<?scenebuilder-preview-i18n-resource «(resource.contents.get(0) as Model).componentDef.previewResourceBundle»?>
		«ENDIF»
		«FOR css: (resource.contents.get(0) as Model).componentDef.previewCssFiles»
		<?scenebuilder-stylesheet «css»?>
		«ENDFOR»
		
		«body»
		«ENDFOR»
	'''
	
	def componentDefinition(ComponentDefinition definition, ImportManager importManager, LanguageManager languageManager, boolean preview, boolean skipController, boolean skipIncludes) '''
		«val element = definition.rootNode»
		«IF definition.dynamicRoot»
		<fx:root xmlns:fx="http://javafx.com/fxml" type="«element.type.shortName(importManager)»"«fxElementAttributes(element,importManager,skipController)»«IF definition.controller != null && ! skipController » fx:controller="«definition.controller.qualifiedName»"«ENDIF»«IF hasAttributeProperties(element,preview)»«elementAttributes(element.properties,preview,skipController)»«elementStaticAttributes(element.staticProperties,importManager,preview,skipController)»«elementStaticCallAttributes(element.staticCallProperties,importManager,preview,skipController)»«ENDIF»>
		«ELSE»
		<«element.type.shortName(importManager)» xmlns:fx="http://javafx.com/fxml"«fxElementAttributes(element,importManager,skipController)»«IF definition.controller != null && ! skipController » fx:controller="«definition.controller.qualifiedName»"«ENDIF»«IF hasAttributeProperties(element,preview)»«elementAttributes(element.properties,preview,skipController)»«elementStaticAttributes(element.staticProperties,importManager,preview,skipController)»«elementStaticCallAttributes(element.staticCallProperties,importManager,preview,skipController)»«ENDIF»>
		«ENDIF»
			«IF definition.defines.size > 0»
			<fx:define>
				«FOR define : definition.defines»
				«IF define.element != null»
					«elementContent(define.element,importManager,preview,skipController,skipIncludes)»
				«ELSEIF define.includeElement != null»
					«IF ! skipIncludes»
					«includeContent(define.includeElement,importManager, preview, skipController, skipIncludes)»
					«ENDIF»
				«ENDIF»
				«ENDFOR»
			</fx:define>
			«ENDIF»
			«IF ! skipController»
			«FOR script : definition.scripts»
				«languageManager.addLanguage(script.language)»
				«IF script.sourcecode != null»
					<fx:script>«script.sourcecode.substring(2,script.sourcecode.length-2)»
					</fx:script>
				«ELSE»
					<fx:script source="«script.source»"/>
				«ENDIF»
			«ENDFOR»
			«ENDIF»
		
			«IF hasNestedProperties(element,preview)»
				«FOR e : element.defaultChildren»
					«elementContent(e,importManager,preview,skipController,skipIncludes)»
				«ENDFOR»
				«propContents(element.properties,importManager,preview,false,skipController,skipIncludes)»
				«statPropContent(element.staticProperties,importManager,preview,skipController,skipIncludes)»
				«statCallPropContent(element.staticCallProperties,importManager,preview,skipController,skipIncludes)»
			«ENDIF»
		«IF definition.dynamicRoot»
		</fx:root>
		«ELSE»
		</«element.type.shortName(importManager)»>
		«ENDIF»
	'''
	
	def CharSequence elementContent(Element element, ImportManager importManager, boolean preview, boolean skipController, boolean skipIncludes) '''
		<«element.type.shortName(importManager)»«fxElementAttributes(element,importManager,skipController)»«IF hasAttributeProperties(element,preview)»«elementAttributes(element.properties,preview,skipController)»«elementStaticAttributes(element.staticProperties,importManager,preview,skipController)»«elementStaticCallAttributes(element.staticCallProperties,importManager,preview,skipController)»«ENDIF»«IF ! hasNestedProperties(element,preview)»/«ENDIF»> 
		«IF hasNestedProperties(element,preview)»
			«FOR e : element.defaultChildren»
				«elementContent(e,importManager,preview,skipController,skipIncludes)»
			«ENDFOR»
			«propContents(element.properties,importManager,preview,false,skipController,skipIncludes)»
			«statPropContent(element.staticProperties,importManager,preview,skipController,skipIncludes)»
			«statCallPropContent(element.staticCallProperties,importManager,preview,skipController,skipIncludes)»
			«FOR e : element.values»
			«IF e instanceof Element»
				«elementContent(e as Element,importManager,preview,skipController,skipIncludes)»
			«ELSEIF e instanceof SimpleValueProperty»
				«objectLiteral(e as SimpleValueProperty)»
			«ENDIF»
			«ENDFOR»
		</«element.type.shortName(importManager)»>
		«ENDIF»
	'''
	
	def objectLiteral(SimpleValueProperty value) {
		if( value.stringValue != null ) {
			return "<String fx:value=\"" + value.stringValue +"\" />";
		} else if( value.booleanValue != null ) {
			return "<Boolean fx:value=\"" + value.booleanValue + "\" />";
		} else if( value.realValue != 0 ) {
			if( value.negative ) {
				return "<Double fx:value=\"-" + value.realValue + "\" />";
			} else {
				return "<Double fx:value=\"" + value.realValue + "\" />";
			}
		} else {
			if( value.negative ) {
				return "<Integer fx:value=\"-" + value.intValue + "\" />";
			} else {
				return "<Integer fx:value=\"" + value.intValue + "\" />";
			}
		}
	}
	
	def CharSequence propContents(List<Property> properties, ImportManager importManager, boolean preview, boolean simpleAsElement, boolean skipController, boolean skipIncludes) '''
		«IF simpleAsElement»
			«FOR prop : properties»
				«propContent(prop,importManager,preview,simpleAsElement,skipController,skipIncludes)»
			«ENDFOR»
		«ELSE»
			«FOR prop : properties.filter([Property p|previewFilter(p,preview)]).filter([Property p|subelementFilter(p)])»
				«propContent(prop,importManager,preview,simpleAsElement,skipController,skipIncludes)»
			«ENDFOR»
		«ENDIF»
	'''
	
	def CharSequence propContent(Property prop, ImportManager importManager, boolean preview, boolean simpleAsElement, boolean skipController, boolean skipIncludes) '''
		«IF prop.value instanceof SimpleValueProperty»
			«IF (prop.value as SimpleValueProperty).stringValue != null»
				<«prop.name»>«(prop.value as SimpleValueProperty).stringValue»</«prop.name»>
			«ELSEIF simpleAsElement»
				<«prop.name»>«(prop.value as SimpleValueProperty).simpleAttributeValue»</«prop.name»>
			«ENDIF»
		«ELSEIF prop.value instanceof ConstValueProperty»
			<«prop.name»><«(prop.value as ConstValueProperty).type.shortName(importManager)» fx:constant="«(prop.value as ConstValueProperty).field»" /></«prop.name»>
		«ELSEIF prop.value instanceof ListValueProperty»
			<«prop.name»>
				«propListContent(prop.value as ListValueProperty,importManager, preview, skipController, skipIncludes)»
			</«prop.name»>
		«ELSEIF prop.value instanceof MapValueProperty»
			<«prop.name»>
				«propContents((prop.value as MapValueProperty).properties,importManager,preview,true,skipController,skipIncludes)»
			</«prop.name»>
		«ELSEIF prop.value instanceof Element»
			<«prop.name»>
				«elementContent(prop.value as Element,importManager,preview, skipController,skipIncludes)»
			</«prop.name»>
		«ELSEIF prop.value instanceof ReferenceValueProperty»
			«IF !skipIncludes»
				<«prop.name»>
					«referenceContent(prop.value as ReferenceValueProperty, importManager, preview, skipController, skipIncludes)»
				</«prop.name»>
			«ENDIF»
		«ELSEIF prop.value instanceof IncludeValueProperty»
			«IF !skipIncludes»
				<«prop.name»>
					«includeContent(prop.value as IncludeValueProperty, importManager, preview, skipController, skipIncludes)»
				</«prop.name»>
			«ENDIF»
		«ELSEIF prop.value instanceof CopyValueProperty»
			<«prop.name»>
				<fx:copy source="«(prop.value as CopyValueProperty).reference.name»" />
			</«prop.name»>
		«ENDIF»
	'''
	
	def CharSequence includeContent(IncludeValueProperty includeElement, ImportManager importManager, boolean preview, boolean skipController, boolean skipIncludes) '''
		<fx:include«IF includeElement.name != null» fx:id="«includeElement.name»"«ENDIF» source="/«includeElement.source.fullyQualifiedName.replaceAll("\\.","/")».fxml"«elementStaticAttributes(includeElement.staticProperties,importManager,preview,skipController)»«elementStaticCallAttributes(includeElement.staticCallProperties,importManager,preview,skipController)» «IF !hasNestedProperties(includeElement,preview)»/«ENDIF»>
		«IF hasNestedProperties(includeElement,preview)»
			«statCallPropContent(includeElement.staticCallProperties, importManager, preview, skipController, skipIncludes)»
			«statPropContent(includeElement.staticProperties, importManager, preview, skipController, skipIncludes)»
		</fx:include>
		«ENDIF»
	'''
	
	def CharSequence referenceContent(ReferenceValueProperty referenceElement, ImportManager importManager, boolean preview, boolean skipController, boolean skipIncludes) '''
		<fx:reference source="«referenceElement.reference.refname»"«elementStaticAttributes(referenceElement.staticProperties,importManager,preview,skipController)»«elementStaticCallAttributes(referenceElement.staticCallProperties,importManager,preview,skipController)» «IF !hasNestedProperties(referenceElement,preview)»/«ENDIF»>
		«IF hasNestedProperties(referenceElement,preview)»
			«statCallPropContent(referenceElement.staticCallProperties, importManager, preview, skipController, skipIncludes)»
			«statPropContent(referenceElement.staticProperties, importManager, preview, skipController, skipIncludes)»
		</fx:reference>
		«ENDIF»
	'''
	
	def statCallPropContent(List<StaticCallValueProperty> properties, ImportManager importManager, boolean preview, boolean skipController, boolean skipIncludes) '''
		«FOR prop : properties.filter([StaticCallValueProperty p|previewFilter(p,preview)]).filter([StaticCallValueProperty p|subelementFilter(p)])»
		«IF prop.value instanceof SimpleValueProperty»
			«IF (prop.value as SimpleValueProperty).stringValue != null»
				<«prop.type.shortName(importManager)».«prop.name»>«(prop.value as SimpleValueProperty).stringValue»</«prop.type.shortName(importManager)».«prop.name»>
			«ELSE»
				<«prop.type.shortName(importManager)».«prop.name»>«simpleAttributeValue(prop.value as SimpleValueProperty)»</«prop.type.shortName(importManager)».«prop.name»>
			«ENDIF»
		«ELSEIF prop.value instanceof ConstValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»><«(prop.value as ConstValueProperty).type.shortName(importManager)» fx:constant="«(prop.value as ConstValueProperty).field»" /></«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof ListValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				«propListContent(prop.value as ListValueProperty,importManager, preview, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof MapValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				«propContents((prop.value as MapValueProperty).properties,importManager,preview,true, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof Element»
			<«prop.type.shortName(importManager)».«prop.name»>
				«elementContent(prop.value as Element,importManager, preview, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof ReferenceValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				«referenceContent(prop.value as ReferenceValueProperty, importManager, preview, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof IncludeValueProperty»
			«IF ! skipIncludes»
				<«prop.type.shortName(importManager)».«prop.name»>
					«includeContent(prop.value as IncludeValueProperty, importManager, preview, skipController, skipIncludes)»
				</«prop.type.shortName(importManager)».«prop.name»>
			«ENDIF»
		«ELSEIF prop.value instanceof CopyValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				<fx:copy source="«(prop.value as CopyValueProperty).reference.name»" />
			</«prop.type.shortName(importManager)».«prop.name»>
		«ENDIF»
		«ENDFOR»
	'''
	
	def statPropContent(List<StaticValueProperty> properties, ImportManager importManager, boolean preview, boolean skipController, boolean skipIncludes) '''
		«FOR prop : properties.filter([StaticValueProperty p|previewFilter(p,preview)]).filter([StaticValueProperty p|subelementFilter(p)])»
		«IF prop.value instanceof SimpleValueProperty»
			«IF (prop.value as SimpleValueProperty).stringValue != null»
				<«prop.type.shortName(importManager)».«prop.name»>«(prop.value as SimpleValueProperty).stringValue»</«prop.type.shortName(importManager)».«prop.name»>
			«ELSE»
				<«prop.type.shortName(importManager)».«prop.name»>«simpleAttributeValue(prop.value as SimpleValueProperty)»</«prop.type.shortName(importManager)».«prop.name»>
			«ENDIF»
		«ELSEIF prop.value instanceof ConstValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»><«(prop.value as ConstValueProperty).type.shortName(importManager)» fx:constant="«(prop.value as ConstValueProperty).field»" /></«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof ListValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				«propListContent(prop.value as ListValueProperty,importManager, preview, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof MapValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				«propContents((prop.value as MapValueProperty).properties,importManager,preview,true, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof Element»
			<«prop.type.shortName(importManager)».«prop.name»>
				«elementContent(prop.value as Element,importManager, preview, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof ReferenceValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				«referenceContent(prop.value as ReferenceValueProperty, importManager, preview, skipController, skipIncludes)»
			</«prop.type.shortName(importManager)».«prop.name»>
		«ELSEIF prop.value instanceof IncludeValueProperty»
			«IF ! skipIncludes»
				<«prop.type.shortName(importManager)».«prop.name»>
					«includeContent(prop.value as IncludeValueProperty, importManager, preview, skipController, skipIncludes)»
				</«prop.type.shortName(importManager)».«prop.name»>
			«ENDIF»
		«ELSEIF prop.value instanceof CopyValueProperty»
			<«prop.type.shortName(importManager)».«prop.name»>
				<fx:copy source="«(prop.value as CopyValueProperty).reference.name»" />
			</«prop.type.shortName(importManager)».«prop.name»>
		«ENDIF»
		«ENDFOR»
	'''
	
	def type(StaticValueProperty prop) {
		var el = prop.eContainer
		while( el.eContainer != null ) {
			if( el.eContainer instanceof Element ) {
				val e = el.eContainer as Element
				return e.type;
			}
			el = el.eContainer;
		}
	}
	
	def refname(ReferenceType e) {
		if( e instanceof Element ) {
			return (e as Element).name;
		} else {
			return (e as IncludeValueProperty).name;
		}
	}
	
	def propListContent(ListValueProperty listProp, ImportManager importManager, boolean preview, boolean skipController, boolean skipIncludes) '''
		«FOR e : listProp.value»
			«IF e instanceof Element»
				«elementContent(e as Element,importManager,preview, skipController, skipIncludes)»
			«ELSEIF e instanceof ReferenceValueProperty»
				«referenceContent(e as ReferenceValueProperty, importManager, preview, skipController, skipIncludes)»
			«ELSEIF e instanceof IncludeValueProperty»
				«IF !skipIncludes»
					«includeContent(e as IncludeValueProperty, importManager, preview, skipController, skipIncludes)»
				«ENDIF»
			«ELSEIF e instanceof SimpleValueProperty»
				«objectLiteral(e as SimpleValueProperty)»
			«ENDIF»
		«ENDFOR»
	'''

    def fullyQualifiedName(ComponentDefinition cp) {
    	val m = cp.eResource.contents.get(0) as Model;
    	
    	if( m.getPackage != null) {
    		return m.getPackage.name + "." + cp.name;
    	} else {
    		return cp.name;
    	}
    }

	def fxElementAttributes(Element element, ImportManager importManager, boolean skipController) {
		var builder = new StringBuilder();
		
		if(element.name != null) {
			builder.append(" fx:id=\""+element.name+"\"");
		}
		
		if( element.value != null ) {
			builder.append(" fx:value=\""+ simpleAttributeValue(element.value) + "\"");
		} else if( element.factory != null ) {
			builder.append(" fx:factory=\""+ element.factory + "\"");
		}
		
		return builder.toString;
	}
	
	def elementAttributes(List<Property> properties, boolean preview, boolean skipController) {
		var builder = new StringBuilder();
		
		for( p : properties.filter([Property p|previewFilter(p,preview)]).filter([Property p|elementAttributeFilter(p)]) ) {
			if( p.value instanceof SimpleValueProperty ) {
				builder.append(" " + p.name + "=\""+simpleAttributeValue(p.value as SimpleValueProperty)+"\"");
			} else if( p.value instanceof ReferenceValueProperty ) {
				builder.append(" " + p.name + "=\"$"+(p.value as ReferenceValueProperty).reference.refname+"\"");
			} else if( p.value instanceof ControllerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.name + "=\"#"+(p.value as ControllerHandledValueProperty).methodname +"\"");
				}
			} else if( p.value instanceof ScriptHandlerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.name + "=\""+(p.value as ScriptHandlerHandledValueProperty).functionname +"\"");
				}
			} else if( p.value instanceof ScriptValueExpression ) {
				if( ! skipController ) {
					builder.append(" " + p.name + "=\""+(p.value as ScriptValueExpression).sourcecode.substring(2,(p.value as ScriptValueExpression).sourcecode.length-2).trim() +";\"");	
				}
			} else if( p.value instanceof ScriptValueReference ) {
				if( ! skipController ) {
					builder.append(" " + p.name + "=\"$"+(p.value as ScriptValueReference).reference + "\"");	
				}
			} else if( p.value instanceof LocationValueProperty ) {
				builder.append(" " + p.name + "=\"@"+(p.value as LocationValueProperty).value+"\"");
			} else if( p.value instanceof ResourceValueProperty ) {
				builder.append(" " + p.name + "=\"%"+(p.value as ResourceValueProperty).value.value+"\"");
			} else if( p.value instanceof BindValueProperty ) {
				builder.append(" " + p.name + "=\"${"+(p.value as BindValueProperty).elementReference.name+"."+(p.value as BindValueProperty).attribute+"}\"");
			}
		}
		
		return builder;
	}
	
	def elementStaticCallAttributes(List<StaticCallValueProperty> properties, ImportManager importManager, boolean preview, boolean skipController) {
		var builder = new StringBuilder();
		
		for( p : properties.filter([StaticCallValueProperty p|previewFilter(p,preview)]).filter([StaticCallValueProperty p|elementAttributeFilter(p)]) ) {
			if( p.value instanceof SimpleValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\""+simpleAttributeValue(p.value as SimpleValueProperty)+"\"");
			} else if( p.value instanceof ReferenceValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"$"+(p.value as ReferenceValueProperty).reference.refname+"\"");
			} else if( p.value instanceof ControllerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"#"+(p.value as ControllerHandledValueProperty).methodname +"\"");
				}
			} else if( p.value instanceof ScriptHandlerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\""+(p.value as ScriptHandlerHandledValueProperty).functionname +"\"");
				}
			} else if( p.value instanceof ScriptValueExpression ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\""+(p.value as ScriptValueExpression).sourcecode.substring(2,(p.value as ScriptValueExpression).sourcecode.length-2).trim() +";\"");	
				}
			} else if( p.value instanceof ScriptValueReference ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"$"+(p.value as ScriptValueReference).reference + "\"");	
				}
			} else if( p.value instanceof LocationValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"@"+(p.value as LocationValueProperty).value+"\"");
			} else if( p.value instanceof ResourceValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"%"+(p.value as ResourceValueProperty).value.value+"\"");
			} else if( p.value instanceof BindValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"${"+(p.value as BindValueProperty).elementReference.name+"."+(p.value as BindValueProperty).attribute+"}\"");
			}
		}
		
		return builder;
	}
	
	def elementStaticAttributes(List<StaticValueProperty> properties, ImportManager importManager, boolean preview, boolean skipController) {
		var builder = new StringBuilder();
		
		for( p : properties.filter([StaticValueProperty p|previewFilter(p,preview)]).filter([StaticValueProperty p|elementAttributeFilter(p)]) ) {
			if( p.value instanceof SimpleValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\""+simpleAttributeValue(p.value as SimpleValueProperty)+"\"");
			} else if( p.value instanceof ReferenceValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"$"+(p.value as ReferenceValueProperty).reference.refname+"\"");
			} else if( p.value instanceof ControllerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"#"+(p.value as ControllerHandledValueProperty).methodname +"\"");
				}
			} else if( p.value instanceof ScriptHandlerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\""+(p.value as ScriptHandlerHandledValueProperty).functionname +"\"");
				}
			} else if( p.value instanceof ScriptValueExpression ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\""+(p.value as ScriptValueExpression).sourcecode.substring(2,(p.value as ScriptValueExpression).sourcecode.length-2).trim() +";\"");	
				}
			} else if( p.value instanceof ScriptValueReference ) {
				if( ! skipController ) {
					builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"$"+(p.value as ScriptValueReference).reference + "\"");	
				}
			} else if( p.value instanceof LocationValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"@"+(p.value as LocationValueProperty).value+"\"");
			} else if( p.value instanceof ResourceValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"%"+(p.value as ResourceValueProperty).value.value+"\"");
			} else if( p.value instanceof BindValueProperty ) {
				builder.append(" " + p.type.shortName(importManager) + "." + p.name + "=\"${"+(p.value as BindValueProperty).elementReference.name+"."+(p.value as BindValueProperty).attribute+"}\"");
			}
		}
		
		return builder;
	}
	
	def subelementFilter(Property property) {
		return ! elementAttributeFilter(property);
	}
	
	def elementAttributeFilter(Property property) {
		return elementAttributeFilter(property.value);
	}
	
	def subelementFilter(StaticCallValueProperty property) {
		return ! elementAttributeFilter(property);
	}

	def elementAttributeFilter(StaticCallValueProperty property) {
		return elementAttributeFilter(property.value);
	}
	
	def subelementFilter(StaticValueProperty property) {
		return ! elementAttributeFilter(property);
	}

	def elementAttributeFilter(StaticValueProperty property) {
		return elementAttributeFilter(property.value);
	}
	
	def elementAttributeFilter(ValueProperty value) {
		if( value instanceof SimpleValueProperty ) {
			return true;
		} else if( value instanceof ReferenceValueProperty ) {
			val r = value as ReferenceValueProperty;
			return r.staticCallProperties.empty && r.staticProperties.empty;
		} else if( value instanceof ControllerHandledValueProperty ) {
			return true;
		} else if( value instanceof ScriptHandlerHandledValueProperty ) {
			return true;
		} else if( value instanceof ScriptValueReference ) {
			return true;
		} else if( value instanceof ScriptValueExpression ) {
			return true;
		} else if( value instanceof LocationValueProperty ) {
			return true;
		} else if( value instanceof ResourceValueProperty ) {
			return true;
		} else if( value instanceof BindValueProperty ) {
			return true;
		}
		return false;
	}

	def simpleAttributeValue(SimpleValueProperty value) {
		if( value.stringValue != null ) {
			return value.stringValue;
		} else if( value.booleanValue != null ) {
			return value.booleanValue;
		} else if( value.realValue != 0 ) {
			if( value.negative ) {
				return "-" + value.realValue;
			} else {
				return value.realValue;
			}
		} else {
			if( value.negative ) {
				return "-" + value.intValue;
			} else {
				return value.intValue;
			}
		}
	}
	
	def previewFilter(Property property, boolean preview) {
		if( ! preview ) {
			if( "preview".equals(property.modifier) ) {
				return false;
			}
		} else {
			if( "runtime-only".equals(property.modifier) ) {
				return false;
			}
		}
		return true;
	}
	
	def previewFilter(StaticCallValueProperty property, boolean preview) {
		if( ! preview ) {
			if( "preview".equals(property.modifier) ) {
				return false;
			}
		} else {
			if( "runtime-only".equals(property.modifier) ) {
				return false;
			}
		}
		return true;
	}
	
	def previewFilter(StaticValueProperty property, boolean preview) {
		if( ! preview ) {
			if( "preview".equals(property.modifier) ) {
				return false;
			}
		} else {
			if( "runtime-only".equals(property.modifier) ) {
				return false;
			}
		}
		return true;
	}
	
	def hasAttributeProperties(Element element, boolean preview) {
		return 
			(
				element.properties.size > 0 
				&& ! element.properties.filter([Property p|previewFilter(p,preview)]).filter([Property p|elementAttributeFilter(p)]).nullOrEmpty
			)
			|| 
			(
				element.staticCallProperties.size > 0
				&& ! element.staticCallProperties.filter([StaticCallValueProperty p|previewFilter(p,preview)]).filter([StaticCallValueProperty p|elementAttributeFilter(p)]).nullOrEmpty
			)
			||
			(
				element.staticProperties.size > 0
				&& ! element.staticProperties.filter([StaticValueProperty p|previewFilter(p,preview)]).filter([StaticValueProperty p|elementAttributeFilter(p)]).nullOrEmpty
			);
	}
	
	def hasNestedProperties(Element element, boolean preview) {
		if( element.values.size > 0 ) {
			return true;
		}
		
		if( element.defaultChildren.size > 0 ) {
			return true;
		}
		
		if( element.staticCallProperties.size > 0) {
			if( ! element.staticCallProperties.filter([StaticCallValueProperty p|previewFilter(p,preview)]).filter([StaticCallValueProperty p|subelementFilter(p)]).nullOrEmpty ) {
				return true;
			}
		}
		
		if( element.staticProperties.size > 0) {
			if( ! element.staticProperties.filter([StaticValueProperty p|previewFilter(p,preview)]).filter([StaticValueProperty p|subelementFilter(p)]).nullOrEmpty ) {
				return true;
			}
		}
		
		if( element.properties.size > 0 ) {
			if( ! element.properties.filter([Property p|previewFilter(p,preview)]).filter([Property p|subelementFilter(p)]).nullOrEmpty ) {
				return true;
			}
		}
		
		return false;
	}
	
	def hasAttributeProperties(IncludeValueProperty element, boolean preview) {
		return 
			(
				element.staticCallProperties.size > 0
				&& ! element.staticCallProperties.filter([StaticCallValueProperty p|previewFilter(p,preview)]).filter([StaticCallValueProperty p|elementAttributeFilter(p)]).nullOrEmpty
			)
			||
			(
				element.staticProperties.size > 0
				&& ! element.staticProperties.filter([StaticValueProperty p|previewFilter(p,preview)]).filter([StaticValueProperty p|elementAttributeFilter(p)]).nullOrEmpty
			);
	}
	
	def hasNestedProperties(IncludeValueProperty element, boolean preview) {
		if( element.staticCallProperties.size > 0) {
			if( ! element.staticCallProperties.filter([StaticCallValueProperty p|previewFilter(p,preview)]).filter([StaticCallValueProperty p|subelementFilter(p)]).nullOrEmpty ) {
				return true;
			}
		}
		
		if( element.staticProperties.size > 0) {
			if( ! element.staticProperties.filter([StaticValueProperty p|previewFilter(p,preview)]).filter([StaticValueProperty p|subelementFilter(p)]).nullOrEmpty ) {
				return true;
			}
		}
		
		return false;
	}
	
	def hasNestedProperties(ReferenceValueProperty element, boolean preview) {
		if( element.staticCallProperties.size > 0) {
			if( ! element.staticCallProperties.filter([StaticCallValueProperty p|previewFilter(p,preview)]).filter([StaticCallValueProperty p|subelementFilter(p)]).nullOrEmpty ) {
				return true;
			}
		}
		
		if( element.staticProperties.size > 0) {
			if( ! element.staticProperties.filter([StaticValueProperty p|previewFilter(p,preview)]).filter([StaticValueProperty p|subelementFilter(p)]).nullOrEmpty ) {
				return true;
			}
		}
		
		return false;
	}
	
	def shortName(JvmTypeReference r, ImportManager importManager) {
		val builder = new StringBuilder()
		importManager.appendType(r.type, builder)
		builder.toString
	}
}
