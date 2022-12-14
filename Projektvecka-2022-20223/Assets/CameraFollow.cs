using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public Transform target;
    public float smoothing = 5f;
    public float aheadDistance = 1f;

    private Vector3 offset;
    private TopDownCharacterMover playerScript;

    void Start()
    {
        offset = transform.position - target.position;
        playerScript = GameObject.Find("Player").GetComponent<TopDownCharacterMover>();
    }

    void FixedUpdate()
    {
        Vector3 newPosition = target.position + offset + -playerScript.movement * aheadDistance;
        transform.position = Vector3.Lerp(transform.position, newPosition, smoothing * Time.fixedDeltaTime);
    }
}

