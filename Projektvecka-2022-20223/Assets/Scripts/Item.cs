using UnityEngine;
//#if UNITY_EDITOR
//using UnityEditor;
//#endif

[CreateAssetMenu(fileName = "New Item", menuName = "Item", order = 0)]
public class Item : ScriptableObject
{
    //#if UNITY_EDITOR
    //    [CustomEditor(typeof(Item))]
    //    public class ItemEditor : Editor
    //    {
    //        public override void OnInspectorGUI()
    //        {
    //            Item script = (Item)target;

    //            EditorGUILayout.BeginHorizontal();
    //            EditorGUILayout.LabelField("Object", EditorStyles.boldLabel, GUILayout.MaxWidth(45));
    //            script._object = (GameObject)EditorGUILayout.ObjectField(script._object, typeof(GameObject), false, GUILayout.MaxWidth(200));
    //            EditorGUILayout.EndHorizontal();
    //        }
    //    }
    //#endif

    [SerializeField] private string itemName = ""; // so multiple items can have the same name
    public string ItemName
    {
        get { return itemName != "" ? itemName : name; }
        set { itemName = value; }
    }

    public GameObject _object;
}