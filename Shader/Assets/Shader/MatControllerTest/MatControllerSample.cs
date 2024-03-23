using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MatControllerSample : MaterialController
{
    [SerializeField] private string secondProperty;
    public float secondValue;
    [SerializeField] private string thirdProperty;
    public float thirdValue;

    public override void EditMaterialPropertiesValue()
    {
        base.EditMaterialPropertiesValue();

        material.SetFloat(secondProperty, secondValue);
        material.SetFloat(thirdProperty, thirdValue);
    }
}