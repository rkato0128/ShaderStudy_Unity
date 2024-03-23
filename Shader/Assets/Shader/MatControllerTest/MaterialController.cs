using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

[RequireComponent(typeof(Graphics))]
[ExecuteInEditMode]
public class MaterialController : UIBehaviour, IMaterialModifier
{

    [NonSerialized]
    private Graphic _graphic;
    public Graphic graphic => _graphic ? _graphic : _graphic = GetComponent<Graphic>();

    [NonSerialized]
    private Material material;

    public float value;
    public string property;
    // 스크립트에서 조정하는 값들 public 으로 변경

    //public readonly int saturationPropertyId = Shader.PropertyToID("_Saturation");

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
        if (material != null) DestroyImmediate(material);
        
        material = null;

        if (graphic != null) _graphic.SetMaterialDirty();

    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();
        if (!IsActive() || graphic == null) return;

        graphic.SetMaterialDirty();
    }
#endif

    protected override void OnDidApplyAnimationProperties()
    {
        // Callback for when properties have been changed by animation. 

        base.OnDidApplyAnimationProperties();
        if (!IsActive() || graphic == null) return;
        graphic.SetMaterialDirty();
    }

    public Material GetModifiedMaterial(Material baseMaterial)
    {
        // 彩度変更に対応していないマテリアルを弾く
        // 채도 변경에 대응하지 않는 메테리얼 처리
        if (IsActive() == false || _graphic == null)
            return baseMaterial;

        // マテリアル複製
        // 메테리얼 복제
        if (material == null)
        {
            material = new Material(baseMaterial);
            material.hideFlags = HideFlags.HideAndDontSave;
            // 컴포넌트에서만 생성, 삭제되는 머테리얼로 지정 / 인스펙터에 표시되지만, 프로퍼티 조정못함
        }

        // これまでのプロパティを引き継ぐ
        // 현재까지의 프로퍼티 값을 인수
        material.CopyPropertiesFromMaterial(baseMaterial);

        material.SetFloat(property, value);

        return material;
    }
}