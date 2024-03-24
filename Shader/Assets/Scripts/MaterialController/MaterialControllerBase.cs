using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

[RequireComponent(typeof(Graphics))]
[ExecuteAlways]
public class MaterialControllerBase : UIBehaviour, IMaterialModifier
{
    [SerializeField] private string firstProperty;
    public float firstValue = 0;

    [NonSerialized]
    private Graphic _graphic;
    public Graphic graphic => _graphic ? _graphic : _graphic = GetComponent<Graphic>();

    [NonSerialized]
    protected Material material;


    protected override void OnEnable()
    {
        base.OnEnable();

        if(graphic == null)
            return;
        
        _graphic.SetMaterialDirty();
    }

    protected override void OnDisable()
    {
        base.OnDisable();

        if (material != null)
            DestroyImmediate(material);
        
        material = null;

        if (graphic != null)
            _graphic.SetMaterialDirty();

    }

#if UNITY_EDITOR
    // 에디터에서 변경사항이 생긴 경우 Dirty 플래그를 통해 GetModifiedMaterial() 호출
    protected override void OnValidate()
    {
        base.OnValidate();

        if (!IsActive() || graphic == null)
            return;

        graphic.SetMaterialDirty();
    }
#endif

    // 애니메이션을 통해 값이 변경되었을 때 Dirty 플래그를 통해 GetModifiedMaterial() 호출
    // Callback for when properties have been changed by animation.
    protected override void OnDidApplyAnimationProperties()
    {
        base.OnDidApplyAnimationProperties();

        if (!IsActive() || graphic == null)
            return;
        
        graphic.SetMaterialDirty();
    }

    // Graphic의 메테리얼에 Dirty 플래그가 설정된 타이밍에 호출됨
    // Perform material modification in this function.
    public Material GetModifiedMaterial(Material baseMaterial) 
    {
        if (IsActive() == false || _graphic == null)
            return baseMaterial;

        if (material == null) // 메테리얼 복제
        {
            material = new Material(baseMaterial);
            material.hideFlags = HideFlags.HideAndDontSave; // 컴포넌트에서만 생성, 삭제되는 머테리얼로 지정 / 인스펙터에 표시되지만, 프로퍼티 조정못함
            
            material.CopyPropertiesFromMaterial(baseMaterial); // 현재까지의 프로퍼티 값을 인수
        }

        EditMaterialPropertiesValue();

        return material;
    }

    public virtual void EditMaterialPropertiesValue() // 자식 클래스에서 조정하는 프로퍼티를 추가할 수 있도록 virtual 로 선언
    {
        material.SetFloat(firstProperty, firstValue);
    }
}