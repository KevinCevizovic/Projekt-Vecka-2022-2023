using UnityEngine;

public class PauseScript : MonoBehaviour
{
    private void OnEnable()
    {
        Pause();
    }

    private void OnDisable()
    {
        UnPause();
    }

    public void Pause() => Time.timeScale = 0f;

    public void UnPause() => Time.timeScale = 1f;
}