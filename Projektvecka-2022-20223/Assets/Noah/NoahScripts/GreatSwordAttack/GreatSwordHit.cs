using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class GreatSwordHit : MonoBehaviour
{
    public GameObject particleSystemPrefab;
    public Transform spearEnd;
    public float maxScale = 3.0f;
    public float holdTime = 2.0f;

    public AudioClip sfxGroundSlam;

    private float currentScale = 1.0f;

    void Update()
    {
        if (Mouse.current.rightButton.wasPressedThisFrame)
        {
            currentScale = 1.0f;
            StartCoroutine(ParticleSizeManipulator());
        }
    }

    public void PlayParticleSystem()
    {
        // Instantiate the particle system prefab
        GameObject particleSystemInstance = Instantiate(particleSystemPrefab, spearEnd.position, Quaternion.identity);

        // Set the rotation of the particle system clone to -90 on the X-axis
        particleSystemInstance.transform.rotation = Quaternion.Euler(-90f, 0f, 0f);

        // Get the ParticleSystem component from the particle system instance
        ParticleSystem particleSystem = particleSystemInstance.GetComponent<ParticleSystem>();

        // Set the scale of the particle system clone based on how long the right mouse button was held down
        particleSystemInstance.transform.localScale = new Vector3(currentScale, currentScale, currentScale);

        // Play the particle system
        particleSystem.Play();

        // Destroy the particle system clone when it's done emitting
        Destroy(particleSystemInstance, particleSystem.main.duration);
    }

    private IEnumerator ParticleSizeManipulator()
    {
        float startTime = Time.time;
        float endTime = 0f;

        while (Mouse.current.rightButton.IsActuated())
        {
            endTime = Time.time;
            currentScale = Mathf.Lerp(1.0f, maxScale, (endTime - startTime) / holdTime);
            yield return null;
        }
    }

    public void PlayGroundSlamSFX()
    {
        AudioSource.PlayClipAtPoint(sfxGroundSlam, transform.position);
    }
}
