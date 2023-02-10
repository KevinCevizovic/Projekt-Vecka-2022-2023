using UnityEngine;

public class PauseAfterTime : MonoBehaviour
{
    [SerializeField] private float time;
    [SerializeField] private bool restartTime = true;

    private float endTime;

    private void Update()
    {
        if (restartTime)
        {
            restartTime = false;
            endTime = Time.time + time;
        }

        if (Time.time >= endTime)
        {
            Debug.Break();
            endTime = Mathf.Infinity;
        }
    }
}