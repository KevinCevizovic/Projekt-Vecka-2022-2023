using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using System.Linq;

public class EnemyAI : MonoBehaviour
{
    [Header("What enemy type?")]
    public bool grunt;
    public bool archer;

    private GameObject player;
    NavMeshAgent agent;

    [Header("Coverpoints")]
    public Transform[] coverPoints;
    GameObject closestTarget;

    [Header("Numbers you change")]
    public float shootRadius = 12.5f;
    public float runRadius = 5f;
    public float hitRadius = 3f;
    public int coverPointIndex;

    Vector3 randomPos;
    public LayerMask mask;
    

    private void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        agent = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    private void Update()
    {
        CollisionChecks();
    }

    private void CollisionChecks()
    {
        // if grunt do this
        if (grunt)
        {
            if (Physics.CheckSphere(transform.position, shootRadius, mask))
            {
                ChasePlayer();
            }
            else if (Physics.CheckSphere(transform.position, hitRadius, mask))
            {
                ShootPlayer();
            }else
            {
                MoveToCover();
            }
        }
        // if archer do this
        if (archer)
        {
            if (Physics.CheckSphere(transform.position, hitRadius, mask))
            {
                ShootPlayer();
            }
            else if (Physics.CheckSphere(transform.position, runRadius, mask))
            {
                AvoidPlayer();
            }
            else if (Physics.CheckSphere(transform.position, shootRadius, mask))
            {
                ShootPlayer();
            }
            else
            {
                MoveToCover();
            }
        }
    }

    private void ShootPlayer()
    {
        var enemies = Physics.OverlapSphere(transform.position, shootRadius, mask);

        float distance = 0;
        for (int i = 0; i < enemies.Length; i++)
        {
            float targetDistance = Vector3.Distance(transform.position, enemies[i].transform.position);
            if (targetDistance < distance || i == 0)
            {
                closestTarget = enemies[i].gameObject;
                distance = targetDistance;
            }
        }
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
        if (archer)
            return;
        var enemies = Physics.OverlapSphere(transform.position, shootRadius, mask);

        float distance = 0;
        for (int i = 0; i < enemies.Length; i++)
        {
            float targetDistance = Vector3.Distance(transform.position, enemies[i].transform.position);
            if (targetDistance < distance || i == 0)
            {
                closestTarget = enemies[i].gameObject;
                distance = targetDistance;
            }
        }

        agent.SetDestination(closestTarget.transform.position);
    }

    private void MoveToCover()
    {
        if((transform.position - coverPoints[coverPointIndex].position).magnitude < 0.4f)
        {
            FaceTarget();
            return;
        }
        agent.SetDestination(coverPoints[coverPointIndex].position);
    }

    private void FaceTarget()
    {
        Vector3 direction = (closestTarget.transform.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(new Vector3(direction.x, 0, direction.z));
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 8.5f);
    }

    private void OnDrawGizmos()
    {
        if (grunt)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(transform.position, shootRadius);
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, hitRadius);

        }
        else if (archer)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(transform.position, shootRadius);
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(transform.position, runRadius);
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, hitRadius);
        }
    }
}