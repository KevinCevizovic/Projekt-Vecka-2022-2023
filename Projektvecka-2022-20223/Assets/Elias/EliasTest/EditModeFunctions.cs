//using UnityEngine;
////using UnityEditor;

////public class EditModeFunctions : EditorWindow
//{
//    //[MenuItem("Window/Edit Mode Functions")]
//    //public static void ShowWindow()
//    //{
//    //    GetWindow<EditModeFunctions>("Edit Mode Functions");
//    //}

//    //private void OnGUI()
//    //{
//    //    if (GUILayout.Button("Spawn all items"))
//    //    {
//    //        ItemShower[] itemShowerArray = FindObjectsOfType<ItemShower>();
//    //        foreach (ItemShower itemShower in itemShowerArray)
//    //            if (itemShower.item != null && itemShower.item._object != null)
//    //                Instantiate(itemShower.item._object, itemShower.transform.position, itemShower.transform.rotation, itemShower.transform);
//    //    }

//    //    if (GUILayout.Button("Delete all items"))
//    //    {
//    //        ItemShower[] itemShowerArray = FindObjectsOfType<ItemShower>();
//    //        foreach (ItemShower itemShower in itemShowerArray)
//    //            if (itemShower.item != null && itemShower.item._object != null)
//    //                while (itemShower.transform.childCount > 0)
//    //                    DestroyImmediate(itemShower.transform.GetChild(itemShower.transform.childCount - 1).gameObject, false);
//    //    }
//    //}
//}