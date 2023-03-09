using UnityEngine;
using UnityEngine.Events;

//[System.Serializable] public class RespawnEvent : UnityEvent { }
public class RespawnScript : MonoBehaviour
{
    [SerializeField] Transform spawnPoint;

    public void Respawn()
    {
        transform.SetPositionAndRotation(spawnPoint.position, spawnPoint.rotation);
    }
}