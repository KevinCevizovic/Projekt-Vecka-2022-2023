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
    //            EditorGUILayout.LabelField("Speed", EditorStyles.boldLabel, GUILayout.MaxWidth(45)); // speed label
    //            EditorGUILayout.LabelField(script.speed.ToString(), GUILayout.MinWidth(100)); // speed text
    //            EditorGUILayout.EndHorizontal();

    //            // debug avg speed toggle
    //            EditorGUILayout.BeginHorizontal();
    //            EditorGUILayout.LabelField("Debug avarage speed", EditorStyles.boldLabel, GUILayout.MaxWidth(150)); // debug avg speed label
    //            script.debugAvgSpeed = EditorGUILayout.ToggleLeft("", script.debugAvgSpeed); // debug avg speed toggle
    //            EditorGUILayout.EndHorizontal();
    //        }
    //    }
    //#endif

    [SerializeField] bool debugAvgSpeed;
    public float speed, avarageSpeed;

    float[] speeds = new float[10];
    Vector3 lastPosition;

    int i = 0;

    private void Update()
    {
        speed = (transform.position - lastPosition).magnitude / Time.deltaTime; // speed of object

        speeds[i] = speed;

        // gets the avarage speed of the last 10 frames
        avarageSpeed = 0;
        foreach (var previousSpeed in speeds)
            avarageSpeed += previousSpeed;
        avarageSpeed /= 10;

        if (debugAvgSpeed)
            Debug.Log(avarageSpeed == 0 ? "0" : $"{avarageSpeed:0.0}"); // logs the avarage speed

        lastPosition = transform.position; // saves position for next frame

        i++;

        if (i >= 10)
            i = 0;
    }
}