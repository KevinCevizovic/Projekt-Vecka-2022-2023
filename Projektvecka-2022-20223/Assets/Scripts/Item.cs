using UnityEngine;
using UnityEditor;

[CreateAssetMenu(fileName = "New Item", menuName = "Item", order = 0)]
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
            script._object = (GameObject)EditorGUILayout.ObjectField(script._object, typeof(GameObject), true, GUILayout.MaxWidth(200));
            EditorGUILayout.EndHorizontal();
        }
    }
#endif

    public GameObject _object;
}