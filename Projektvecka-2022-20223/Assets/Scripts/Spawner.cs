using UnityEngine;

public class Spawner : MonoBehaviour
{
    [SerializeField] private GameObject gruntEnemy;
    [SerializeField] private GameObject archerEnemy;
    [SerializeField] private GameObject gruntAlly;
    [SerializeField] private GameObject archerAlly;
    private float timer = 10f;
    public float targetTime = 15f;
    [SerializeField] private Transform enemySpawnPoint;
    [SerializeField] private Transform allySpawnPoint;
    [SerializeField] bool enemySpawner;


    //void Awake()
    //{
        //ObjectPool.Preload(gruntEnemy, 40);
        //ObjectPool.Preload(archerEnemy, 20);
        //ObjectPool.Preload(gruntAlly, 40);
        //ObjectPool.Preload(archerAlly, 20);
    //}

    void Update()
    {
        timer -= Time.deltaTime;
        if (timer <= 0f)
        {
            timer -= timer;
            timer = targetTime;
            Spawn();
        }
    }

    void Spawn()
    {
        // Spawn enemies
        if (enemySpawner)
        {
            ObjectPool.Spawn(gruntEnemy, enemySpawnPoint.position + new Vector3(Random.Range(0, 10), 0, Random.Range(0, 10)), Quaternion.identity).transform.parent = transform;
            ObjectPool.Spawn(gruntEnemy, enemySpawnPoint.position + new Vector3(Random.Range(0, 10), 0, Random.Range(0, 10)), Quaternion.identity).transform.parent = transform;
            ObjectPool.Spawn(archerEnemy, enemySpawnPoint.position + new Vector3(Random.Range(0, 10), 0, Random.Range(0, 10)), Quaternion.identity).transform.parent = transform;
        }

        if (enemySpawner)
            return;
        // Spawn allies
        ObjectPool.Spawn(gruntAlly, allySpawnPoint.position + new Vector3(Random.Range(0, 10), 0, Random.Range(0, 10)), Quaternion.identity).transform.parent = transform;
        ObjectPool.Spawn(archerAlly, allySpawnPoint.position + new Vector3(Random.Range(0, 10), 0, Random.Range(0, 10)), Quaternion.identity).transform.parent = transform;
    }
}