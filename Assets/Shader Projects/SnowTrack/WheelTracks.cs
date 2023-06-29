using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WheelTracks : MonoBehaviour
{
    public Shader DrawShader; // DrawTracks
    [Range(0, 2)]
    public float BrushSize;
    [Range(0, 1)]
    public float BrushStrength;
    public GameObject Terrain;
    public Transform[] Wheels;

    private RenderTexture trackTexture;
    private Material snowMaterial;
    private Material drawMateral;
    private RaycastHit hit;
    private int layerMask;
    
    // Start is called before the first frame update
    void Start()
    {
        layerMask = LayerMask.GetMask("Ground");
        drawMateral = new Material(DrawShader);
        drawMateral.SetVector("_Color", Color.red);
        drawMateral.SetFloat("_Size", BrushSize);
        drawMateral.SetFloat("_Strength", BrushStrength);

        snowMaterial = Terrain.GetComponent<MeshRenderer>().material;
        trackTexture = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        snowMaterial.SetTexture("_Track", trackTexture);
    }

    // Update is called once per frame
    void Update()
    {
        for (int i = 0; i < Wheels.Length; i++)
        {
            // 可以拿到碰撞对象的UV信息
            if (Physics.Raycast(Wheels[i].position, Vector3.down, out hit, 1f, layerMask))
            {
                //拿到的是纹理UV
                drawMateral.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                // 获得一个临时 获取一个临时RenderTexture,和trackTexture大小一致
                var tempTex = RenderTexture.GetTemporary(trackTexture.width, trackTexture.height, 0, RenderTextureFormat.ARGBFloat);
                // 将trackTexture绘制到临时RenderTexture
                Graphics.Blit(trackTexture, tempTex);
                // 使用drawMateral材质将临时RenderTexture绘制到trackTexture, trackTexture拿到tempTex的pixelData，传入shader渲染。
                Graphics.Blit(tempTex, trackTexture, drawMateral);
                RenderTexture.ReleaseTemporary(tempTex);
            }
        }
    }
}
