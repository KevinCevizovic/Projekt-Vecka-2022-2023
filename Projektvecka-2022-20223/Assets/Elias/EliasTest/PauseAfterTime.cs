using UnityEngine;

public class PauseAfterTime : MonoBehaviour
{
    [SerializeField] private float time;
    [SerializeField] private bool startTime = true;

    private float endTime;

    private void Start()
    {
        if (!startTime)
            endTime = Mathf.Infinity;
    }

    private void Update()
    {
        if (startTime)
        {
            startTime = false;
            endTime = Time.time + time;
        }

        if (Time.time >= endTime)
        {
            Debug.Break();
            endTime = Mathf.Infinity;
        }
    }
}