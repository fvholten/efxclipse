/**
 */
package org.eclipse.fx.code.compensator.hsl.hSL.impl;

import java.util.Collection;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;

import org.eclipse.emf.ecore.util.EDataTypeEList;

import org.eclipse.fx.code.compensator.hsl.hSL.HSLPackage;
import org.eclipse.fx.code.compensator.hsl.hSL.ScannerCharacterRule;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Scanner Character Rule</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * <ul>
 *   <li>{@link org.eclipse.fx.code.compensator.hsl.hSL.impl.ScannerCharacterRuleImpl#getCharacters <em>Characters</em>}</li>
 * </ul>
 * </p>
 *
 * @generated
 */
public class ScannerCharacterRuleImpl extends ScannerRuleImpl implements ScannerCharacterRule
{
  /**
   * The cached value of the '{@link #getCharacters() <em>Characters</em>}' attribute list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getCharacters()
   * @generated
   * @ordered
   */
  protected EList<String> characters;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected ScannerCharacterRuleImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return HSLPackage.Literals.SCANNER_CHARACTER_RULE;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public EList<String> getCharacters()
  {
    if (characters == null)
    {
      characters = new EDataTypeEList<String>(String.class, this, HSLPackage.SCANNER_CHARACTER_RULE__CHARACTERS);
    }
    return characters;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case HSLPackage.SCANNER_CHARACTER_RULE__CHARACTERS:
        return getCharacters();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @SuppressWarnings("unchecked")
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case HSLPackage.SCANNER_CHARACTER_RULE__CHARACTERS:
        getCharacters().clear();
        getCharacters().addAll((Collection<? extends String>)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case HSLPackage.SCANNER_CHARACTER_RULE__CHARACTERS:
        getCharacters().clear();
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case HSLPackage.SCANNER_CHARACTER_RULE__CHARACTERS:
        return characters != null && !characters.isEmpty();
    }
    return super.eIsSet(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public String toString()
  {
    if (eIsProxy()) return super.toString();

    StringBuffer result = new StringBuffer(super.toString());
    result.append(" (characters: ");
    result.append(characters);
    result.append(')');
    return result.toString();
  }

} //ScannerCharacterRuleImpl
