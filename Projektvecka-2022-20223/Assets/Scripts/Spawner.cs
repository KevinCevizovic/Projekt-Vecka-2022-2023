using UnityEngine;

public class Spawner : MonoBehaviour
{
    [SerializeField] private GameObject gruntEnemy;
    [SerializeField] private GameObject archerEnemy;
    [SerializeField] private GameObject gruntAlly;
    [SerializeField] private GameObject archerAlly;
    private float timer = 10f;
    public float targetTime = 15f;
    [SerializeField] private Transform[] enemySpawnPoints;
    [SerializeField] private Transform[] allySpawnPoints;
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
            ObjectPool.Spawn(gruntEnemy, enemySpawnPoints[0].position + new Vector3(Random.Range(0, 1), transform.position.y + 1f, Random.Range(0, 11)), Quaternion.identity).transform.parent = transform;
            ObjectPool.Spawn(gruntEnemy, enemySpawnPoints[1].position + new Vector3(Random.Range(0, 1), transform.position.y + 1f, Random.Range(0, 1)), Quaternion.identity).transform.parent = transform;
            ObjectPool.Spawn(archerEnemy, enemySpawnPoints[2].position + new Vector3(Random.Range(0, 1), transform.position.y + 1f, Random.Range(0, 11)), Quaternion.identity).transform.parent = transform;
        }

        if (enemySpawner)
            return;
        // Spawn allies
        ObjectPool.Spawn(gruntAlly, allySpawnPoints[0].position + new Vector3(Random.Range(0, 1), transform.position.y + 1f, Random.Range(0, 1)), Quaternion.identity).transform.parent = transform;
        ObjectPool.Spawn(archerAlly, allySpawnPoints[1].position + new Vector3(Random.Range(0, 1), transform.position.y + 1f, Random.Range(0, 1)), Quaternion.identity).transform.parent = transform;
    }
}