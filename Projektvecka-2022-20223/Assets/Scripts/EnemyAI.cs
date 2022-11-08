using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyAI : MonoBehaviour
{
    public GameObject player;
    NavMeshAgent agent;

    public float shootRadius = 12.5f;
    public float runRadius = 5f;
    public float hitRadius = 3f;
    Vector3 randomPos;
    public LayerMask mask;
    

    private void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        agent = GetComponent<NavMeshAgent>();
    }
    private void Start()
    {
        randomPos = new Vector3(Random.Range(-1, 1), 0, Random.Range(-1, 1));
    }
    // Update is called once per frame
    private void Update()
    {
        CollisionChecks();
    }

    private void CollisionChecks()
    {
        if (Physics.CheckSphere(transform.position, hitRadius, mask))
        {
            Debug.Log("Hitting");
            ShootPlayer();
        }
        else if (Physics.CheckSphere(transform.position, runRadius, mask))
        {
            Debug.Log("Running");
            AvoidPlayer();
        }
        else if (Physics.CheckSphere(transform.position, shootRadius, mask))
        {
            Debug.Log("Shooting");
            ShootPlayer();
        }else
        {
            Debug.Log("Chasing");
            ChasePlayer();
        }
        
    }

    private void ShootPlayer()
    {
        agent.SetDestination(transform.position);
    }

    private void AvoidPlayer()
    {
        Vector3 dirToPlayer = transform.position - player.transform.position;

        Vector3 newPos = transform.position + dirToPlayer;

        agent.SetDestination(newPos);
    }

    private void ChasePlayer()
    {
        
        agent.SetDestination(player.transform.position + randomPos);
    }


    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position, shootRadius);
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, runRadius);
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, hitRadius);
    }
}