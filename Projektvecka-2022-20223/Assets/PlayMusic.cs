using UnityEngine;

public class PlayMusic : MonoBehaviour
{
    [SerializeField] private AudioSource music;

    public void PlayOrStop()
    {
        if (music.isPlaying)
            music.Stop();
        else music.Play();
    }
}