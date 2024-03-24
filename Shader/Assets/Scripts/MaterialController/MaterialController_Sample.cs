using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MaterialController_Sample : MaterialControllerBase
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

        // 추가 속성값들 편집
    }
}