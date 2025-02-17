using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//通过随机数减去主纹理的颜色值,在屏幕上生成雪花效果
public class SnowNoise : MonoBehaviour
{
    public Shader SnowFallShader;
    [Range(0.001f, 0.1f)]
    public float FlakeAmount;
    [Range(0, 1)]
    public float FlakeOpacity;

    private Material snowFallMaterial;
    private MeshRenderer meshRenderer;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        snowFallMaterial = new Material(SnowFallShader);
    }

    void Update()
    {
        snowFallMaterial.SetFloat("_FlakeAmount", FlakeAmount);
        snowFallMaterial.SetFloat("_FlakeOpacity", FlakeOpacity);
        var snow = (RenderTexture)meshRenderer.material.GetTexture("_Track"); // snow track 材质
        var tmp = RenderTexture.GetTemporary(snow.width, snow.height, 0, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(snow, tmp, snowFallMaterial);
        Graphics.Blit(tmp, snow);
        meshRenderer.material.SetTexture("_Track", snow);
        RenderTexture.ReleaseTemporary(tmp);
    }
}
