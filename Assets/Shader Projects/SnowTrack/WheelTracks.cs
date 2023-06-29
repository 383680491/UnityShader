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
            // �����õ���ײ�����UV��Ϣ
            if (Physics.Raycast(Wheels[i].position, Vector3.down, out hit, 1f, layerMask))
            {
                //�õ���������UV
                drawMateral.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                // ���һ����ʱ ��ȡһ����ʱRenderTexture,��trackTexture��Сһ��
                var tempTex = RenderTexture.GetTemporary(trackTexture.width, trackTexture.height, 0, RenderTextureFormat.ARGBFloat);
                // ��trackTexture���Ƶ���ʱRenderTexture
                Graphics.Blit(trackTexture, tempTex);
                // ʹ��drawMateral���ʽ���ʱRenderTexture���Ƶ�trackTexture, trackTexture�õ�tempTex��pixelData������shader��Ⱦ��
                Graphics.Blit(tempTex, trackTexture, drawMateral);
                RenderTexture.ReleaseTemporary(tempTex);
            }
        }
    }
}
