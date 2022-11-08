using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyAI : MonoBehaviour
{
    public GameObject player;
    NavMeshAgent agent;
    public Transform[] coverPoints;

    public float shootRadius = 12.5f;
    public float runRadius = 5f;
    public float hitRadius = 3f;
    private int randomInt;

    Vector3 randomPos;
    public LayerMask mask;
    

    private void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        agent = GetComponent<NavMeshAgent>();
    }

    private void Start()
    {
        randomInt = Random.Range(0, coverPoints.Length);
        Debug.Log(randomInt);
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
            Debug.Log("Move to cover");
            MoveToCover();
        }
        
    }

    private void ShootPlayer()
    {
        agent.SetDestination(transform.position);
        FaceTarget();
    }

    private void AvoidPlayer()
    {
        Vector3 dirToPlayer = transform.position - player.transform.position;

        Vector3 newPos = transform.position + dirToPlayer;

        agent.SetDestination(newPos);
        FaceTarget();
    }

    private void ChasePlayer()
    {
        //agent.SetDestination(player.transform.position + randomPos);
    }

    private void MoveToCover()
    {
        agent.SetDestination(coverPoints[randomInt].position);
    }

    private void FaceTarget()
    {
        Vector3 direction = (player.transform.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(new Vector3(direction.x, 0, direction.z));
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 8.5f);
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