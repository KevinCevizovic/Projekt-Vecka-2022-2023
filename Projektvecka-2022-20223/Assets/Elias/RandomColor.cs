//using UnityEditor;
using UnityEngine;

public class RandomColor : MonoBehaviour
{
//#if UNITY_EDITOR
//    [CustomEditor(typeof(RandomColor))]
//    public class RandomColorEditor : Editor
//    {
//        public override void OnInspectorGUI()
//        {
//            RandomColor script = (RandomColor)target;

//            base.OnInspectorGUI();

//            if (Application.isPlaying)
//                if (GUILayout.Button("Change Color", GUILayout.MinHeight(100)))
//                    script.ChangeColor();
//        }
//    }
//#endif


    // applies random color on press or on start
    // GUI; Color,Change color button,slider for minValue
    public Color color;
    [Range(0f, 1f)]
    [SerializeField] float minValue = 0f, maxValue = 1f;

    private SpriteRenderer spriteRenderer;
    private MeshRenderer meshrender;

    private void OnValidate()
    {
        if (spriteRenderer == null)
            TryGetComponent(out spriteRenderer);

        if (meshrender == null)
            TryGetComponent(out meshrender);
    }

    private void Awake()
    {
        if (spriteRenderer == null)
            TryGetComponent(out spriteRenderer);

        if (meshrender == null)
            TryGetComponent(out meshrender);
    }

    private void Start()
    {
        ChangeColor();
    }

    public void ChangeColor()
    {
        color = Random.ColorHSV(0f, 1f, 1f, 1f, minValue, maxValue);

        if (spriteRenderer != null)
            spriteRenderer.color = color;
        else
            if (meshrender != null)
            meshrender.material.color = color;
    }
}