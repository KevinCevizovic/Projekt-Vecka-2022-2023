using UnityEngine;
using UnityEditor;

[CreateAssetMenu(fileName = "New Item", menuName = "Item"/*"Item/Normal Item"*/)]
public class Item : ScriptableObject
{
#if UNITY_EDITOR
    [CustomEditor(typeof(Item))]
    public class ItemEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            Item script = (Item)target;

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Object", EditorStyles.boldLabel, GUILayout.MaxWidth(45));
            script._object = (GameObject)EditorGUILayout.ObjectField(script._object == null ? null : script._object, typeof(GameObject), true, GUILayout.MaxWidth(200));
            EditorGUILayout.EndHorizontal();

            if (script.collictible)
            {
                if (script.collectibleScript == null && script._object != null && script._object.TryGetComponent(out CollectibleScript collectibleScript)) // gets script if null and object isnt null and object has script
                    script.collectibleScript = collectibleScript;

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("Script:", EditorStyles.boldLabel, GUILayout.MaxWidth(45));
                EditorGUILayout.LabelField(script.collectibleScript != null ? script.collectibleScript.GetType().ToString() : "Missing", EditorStyles.label, GUILayout.MinWidth(200));
                EditorGUILayout.EndHorizontal();
            }
            else script.collectibleScript = null; // collectibleScript is null if item isnt a collectible

            // collectible toggle with bold text
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Collectible", EditorStyles.label, GUILayout.MaxWidth(75));
            script.collictible = EditorGUILayout.ToggleLeft("", script.collictible); // collectible toggle
            EditorGUILayout.EndHorizontal();
        }
    }
#endif

    public GameObject _object;

    public bool collictible;

    [SerializeField] private CollectibleScript collectibleScript;
}