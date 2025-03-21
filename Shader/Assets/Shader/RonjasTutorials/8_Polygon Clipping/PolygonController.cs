using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class PolygonController : MonoBehaviour
{
    [SerializeField]
    private Vector2[] corners;

    private Material _mat;

    void UpdateMaterial()
    {
        // 아직 메테리얼을 가져오지 않았다면 가져오기
        if(_mat == null)
            _mat = GetComponent<Renderer>().sharedMaterial;

        // 셰이더로 전달할 배열 할당 및 채우기
        Vector4[] vec4Corners = new Vector4[1000];

        for(int i=0 ;i<corners.Length; i++)
        {
            vec4Corners[i] = corners[i];
        }

        // 배열을 메테리얼에 전달
        _mat.SetVectorArray("_corners", vec4Corners);
        _mat.SetInt("_cornerCount", corners.Length);
    }

    void Start()
    {
        UpdateMaterial();
    }

    void OnValidate()
    {
        UpdateMaterial();
    }
}