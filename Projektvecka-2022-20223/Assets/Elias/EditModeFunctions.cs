using UnityEngine;
using UnityEditor;

public class EditModeFunctions : EditorWindow
{
    [MenuItem("Window/Edit Mode Functions")]
    public static void ShowWindow()
    {
        GetWindow<EditModeFunctions>("Edit Mode Functions");
    }

    private void OnGUI()
    {
        if (GUILayout.Button("Spawn all items"))
        {
            ItemShower[] itemShowerArray = FindObjectsOfType<ItemShower>();
            foreach (ItemShower item in itemShowerArray)
                Instantiate(item.item, item.gameObject.transform);
        }

        if (GUILayout.Button("Delete all Items"))
        {
            ItemShower[] itemShowerArray = FindObjectsOfType<ItemShower>();
            foreach (ItemShower item in itemShowerArray)
                DestroyImmediate(item.transform.GetChild(item.transform.childCount - 1), false);
        }
    }
}