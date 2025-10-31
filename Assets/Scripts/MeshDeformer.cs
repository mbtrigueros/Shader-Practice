using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class MeshDeformer : MonoBehaviour
{
    public ComputeShader computeShader;
    public Transform player;

    public float deformAmount = 0.1f;
    public float deformRadius = 3.0f;

    private Mesh mesh;
    private Vector3[] vertices;
    private GraphicsBuffer vertexBuffer;
    private int kernel;
    private int vertexCount;

    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;

        if (!mesh.isReadable)
        {
            Debug.LogError("Mesh must be Read/Write enabled in import settings.");
            return;
        }

        vertices = mesh.vertices;
        vertexCount = vertices.Length;

        // Crear el buffer y cargar los vértices
        vertexBuffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, vertexCount, sizeof(float) * 3);
        vertexBuffer.SetData(vertices);

        kernel = computeShader.FindKernel("CSMain");
    }

    void Update()
    {
        if (vertexBuffer == null || player == null) return;

        // Pasar datos al compute shader
        computeShader.SetFloat("_Time", Time.time);
        computeShader.SetFloat("_DeformAmount", deformAmount);
        computeShader.SetFloat("_DeformRadius", deformRadius);
        computeShader.SetInt("_VertexCount", vertexCount);
        computeShader.SetVector("_TargetPosition", player.position);
        computeShader.SetBuffer(kernel, "vertices", vertexBuffer);

        // Ejecutar shader
        int threadGroups = Mathf.CeilToInt(vertexCount / 64f);
        computeShader.Dispatch(kernel, threadGroups, 1, 1);

        // Leer los resultados de vuelta
        vertexBuffer.GetData(vertices);
        mesh.vertices = vertices;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }

    void OnDestroy()
    {
        if (vertexBuffer != null)
            vertexBuffer.Release();
    }
}