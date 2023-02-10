using System.Collections.Generic;
//using UnityEditor;
using UnityEngine;

public class SpeedChecker : MonoBehaviour
{
//#if UNITY_EDITOR
//    [CustomEditor(typeof(SpeedChecker))]
//    public class SpeedCheckerEditor : Editor
//    {
//        public override void OnInspectorGUI()
//        {
//            SpeedChecker script = (SpeedChecker)target;

//            // speed text
//            EditorGUILayout.BeginHorizontal();
//            EditorGUILayout.LabelField("Speed", EditorStyles.boldLabel, GUILayout.MaxWidth(45)); // bold text
//            EditorGUILayout.LabelField(script.speed.ToString(), GUILayout.MinWidth(100)); // normal text
//            EditorGUILayout.EndHorizontal();

//            // debug avg speed toggle
//            EditorGUILayout.BeginHorizontal();
//            EditorGUILayout.LabelField("Debug avarage speed", EditorStyles.boldLabel, GUILayout.MaxWidth(150));
//            script.debugAvgSpeed = EditorGUILayout.ToggleLeft("", script.debugAvgSpeed); // debug avg speed toggle
//            EditorGUILayout.EndHorizontal();
//        }
//    }
//#endif

    [SerializeField] bool debugAvgSpeed;
    public float speed, avarageSpeed;

    List<float> speeds = new();
    readonly int nrOfFramesToAvgFrom = 10;
    Vector3 lastPosition;

    private void Update()
    {
        speed = (lastPosition - transform.position).magnitude / Time.deltaTime; // speed of object

        // makes a list of speeds within 10 frames
        if (speeds.Count < nrOfFramesToAvgFrom)
            speeds.Add(speed);
        else
        {
            speeds.Insert(0, speed);
            speeds.RemoveAt(nrOfFramesToAvgFrom);
        }

        // gets the avarage speed of the list
        avarageSpeed = 0;
        foreach (var previousSpeed in speeds)
            avarageSpeed += previousSpeed;
        avarageSpeed /= nrOfFramesToAvgFrom;


        lastPosition = transform.position; // saves position for next frame

        if (debugAvgSpeed)
            Debug.Log(avarageSpeed == 0 ? "0" : $"{avarageSpeed:0.0}"); // logs the avarage speed
    }
}