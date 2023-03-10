using System.Collections;
using UnityEngine;
using UnityEngine.Events;

[System.Serializable] public class RespawnEvent : UnityEvent { }
public class RespawnScript : MonoBehaviour
{
    private GameObject[] spawnPoints;

    public RespawnEvent OnRespawn, OnRespawned;

    private void Awake()
    {
        spawnPoints = GameObject.FindGameObjectsWithTag("SpawnPoint");
    }

    public void Respawn()
    {
        OnRespawn?.Invoke();
        Debug.Log(OnRespawn);
        if (spawnPoints.Length == 0)
        {
            Debug.LogWarning("No SpawnPoints");
            transform.position = Vector3.zero;
            return;
        }

        float current = 0f;
        float smallest = 0f;
        var e = spawnPoints[0];
        foreach (var spawnPoint in spawnPoints)
        {
            current = Vector3.Distance(transform.position, spawnPoint.transform.position);
            if (current < smallest)
            {
                smallest = current;
                e = spawnPoint;
            }
        }

        //yield return new WaitUntil(() => true);


        transform.SetPositionAndRotation(e.transform.position, e.transform.rotation);
        Debug.Log(OnRespawned);
        OnRespawned?.Invoke();
    }
}