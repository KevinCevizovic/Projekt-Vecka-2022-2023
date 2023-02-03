using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Trigger : MonoBehaviour
{
    public UnityEvent triggerEnter;
    public UnityEvent triggerExit;

    public string otherTag;

    void Start()
    {
        if (triggerEnter == null)
            triggerEnter = new UnityEvent();
        if (triggerExit == null)
            triggerExit = new UnityEvent();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag(otherTag))
        {
            triggerEnter.Invoke();
        }   
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag(otherTag))
            triggerExit.Invoke();
    }
}
