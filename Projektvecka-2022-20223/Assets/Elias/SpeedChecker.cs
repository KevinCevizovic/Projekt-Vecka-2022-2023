using System.Collections.Generic;
using UnityEngine;

public class SpeedChecker : MonoBehaviour
{
    public float avarageSpeed, speed;
    [SerializeField] bool debugAvgSpeed;


    [SerializeField] List<float> speeds = new();

    readonly int nrOfFramesToAvgFrom = 10;
    Vector3 lastPosition;

    private void Update()
    {
        speed = (lastPosition - transform.position).magnitude / Time.deltaTime; // speed of object

        // Gets avarage speed from 10 frames

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