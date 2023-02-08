using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class EnemyAI : MonoBehaviour
{
    [Header("What enemy type?")]
    public bool grunt;
    public bool archer;

    private GameObject player;
    NavMeshAgent agent;

    [Header("Coverpoints")]
    public int coverPointIndex;
    public Transform[] coverPoints;
    public Vector3 randomPosition = Vector3.zero;
    public GameObject closestTarget;
    public GameObject bullet;

    [Header("Numbers you change")]
    [Range(6f, 20f)]
    public float shootRadius = 12.5f;
    [Range(2f, 6f)]
    public float runRadius = 5f;
    [Range(0, 3f)]
    public float hitRadius = 3f;
    [Range(0, 100)]
    public float damage = 3f;
    [Range(0.1f, 10f)]
    public float timeBetweenShooting = 2.5f;

    [Range(0.5f, 3.5f)]
    public float speedNotChasing = 1.5f;
    [Range(3.5f, 6f)]
    public float speedChasing = 3.5f;

    public LayerMask enemyMask;
    private LayerMask myMask;
    public LayerMask obstacleMask;

    EnemyAI[] enemyAIs;
    Coroutine myRoutine;
    public States currentState;

    public float followUpTimer = 2f;

    private bool isCallingCoroutine = false;
    private Vector3 homePos;

    // Start is called before the first frame update
    private void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        agent = GetComponent<NavMeshAgent>();
        //randomPosition = new Vector3(transform.position.x + Random.Range(-10, 10), transform.position.y, transform.position.z + Random.Range(-10, 10));
    }

    private void Start()
    {
        homePos = transform.position;
        homePos.y = 0;
    }

    public enum States
    {
        IdleWalking,
        Chasing,
        Shooting,
        Hitting,
        FollowingPlayer,
        Avoiding,
        GoingHome
    }

    // Update is called once per frame
    void Update()
    {
        if (currentState == States.FollowingPlayer)
        {
            FollowPlayer();
        }
        else
        {
            CollisionChecks();
        }
        // anim.SetFloat("move", agent.velocity.magnitude);
    }

    private void CollisionChecks()
    {
        var enemies = Physics.OverlapSphere(transform.position, 1000000, enemyMask);

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

        Vector3 toOther = closestTarget.transform.position - transform.position;
        // if grunt do this
        if (grunt)
        {
            if (Physics.CheckSphere(transform.position, hitRadius, enemyMask))
            {
                FaceTarget();
                currentState = States.Hitting;
                if (!isCallingCoroutine)
                    StartCoroutine(Attack());
            }
            else if (Physics.CheckSphere(transform.position, shootRadius, enemyMask) &&
                !Physics.Linecast(transform.position + Vector3.up, closestTarget.transform.position, obstacleMask) &&
                Vector3.Dot(transform.forward, toOther) > 0.2)
            {
                ChaseTarget();
                followUpTimer = 2f;
            }
            else
            {
                followUpTimer -= Time.deltaTime;
                if (followUpTimer > 0)
                {
                    ChaseTarget();
                }
                else
                {
                    MoveToCover();
                }
            }
        }
        // if archer do this
        if (archer)
        {
            if (Physics.CheckSphere(transform.position, hitRadius, enemyMask))
            {
                Debug.Log("Hitting");
                if (!isCallingCoroutine)
                {
                    StartCoroutine(Attack());
                }
            }
            else if (Physics.CheckSphere(transform.position, runRadius, enemyMask))
            {
                Debug.Log("Avoiding");
                AvoidPlayer();
            }
            else if (Physics.CheckSphere(transform.position, shootRadius, enemyMask) &&
                !Physics.Linecast(transform.position + Vector3.up, closestTarget.transform.position, obstacleMask) &&
                Vector3.Dot(transform.forward, toOther) > 0.25f)
            {
                FaceTarget();
                if (!isCallingCoroutine)
                {
                    StartCoroutine(Attack());
                }
                Debug.Log("Shooting");
            }
            else
            {
                MoveToCover();
            }
        }
    }

    private void FollowPlayer()
    {
        currentState = States.FollowingPlayer;
        agent.SetDestination(player.transform.position);
    }

    private IEnumerator Attack()
    {
        isCallingCoroutine = true;
        currentState = States.Shooting;
        if (grunt)
        {
            agent.SetDestination(transform.position);
            yield return new WaitForSeconds(timeBetweenShooting);
            isCallingCoroutine = false;
            Debug.Log("Hit");
            Collider[] hitTargets = Physics.OverlapSphere(transform.position + transform.forward, hitRadius, enemyMask);
            foreach (Collider enemy in hitTargets)
            {
                try
                {
                    enemy.GetComponent<Health>().TakingDamage(damage);
                }
                catch
                {
                    Debug.Log("No health script in target");
                }

            }
        }
        else if (archer)
        {
            agent.SetDestination(transform.position);
            yield return new WaitForSeconds(timeBetweenShooting);
            isCallingCoroutine = false;
            Debug.Log("Hit");
            GameObject newBullet = Instantiate(bullet, transform.position + transform.forward, Quaternion.identity);
            newBullet.GetComponent<Rigidbody>().AddForce(transform.forward * 1000f);
            newBullet.GetComponent<Projectile>().damage = this.damage;
            newBullet.GetComponent<Projectile>().attackLayer = enemyMask;
        }
    }
    /*
    private void MessageOtherTeammates()
    {
        Debug.Log("Message Other");
        myMask = gameObject.layer;
        List<GameObject> gameObjects = new List<GameObject>();
        gameObjects.AddRange(Physics.OverlapSphere(transform.position, shootRadius + 100000f, myMask).Select(enemyCollider => enemyCollider.gameObject));
        foreach (GameObject enemy in gameObjects)
        {
            if (enemy.GetComponent<EnemyAI>().seesPlayer)
                continue;
            else
            {
                enemy.GetComponent<EnemyAI>().AvoidPlayer();
            }
        }
    }
    */
    private void AvoidPlayer()
    {
        currentState = States.Avoiding;
        agent.speed = speedChasing;
        Vector3 dirToPlayer = transform.position - player.transform.position;

        Vector3 newPos = transform.position + dirToPlayer;

        agent.SetDestination(newPos);
        FaceTarget();
    }

    private void ChaseTarget()
    {
        if (archer)
            return;
        currentState = States.Chasing;
        agent.speed = speedChasing;
        agent.SetDestination(closestTarget.transform.position);
    }

    private void MoveToCover()
    {
        // Animation things
        
        agent.speed = speedNotChasing;
        Vector3 newPos = transform.position;
        newPos.y = 0;

        if ((homePos - newPos).magnitude > 30f)
        {
            currentState = States.GoingHome;
            agent.SetDestination(homePos);
            Debug.Log("Going home");
        }
        if ((transform.position - randomPosition).magnitude < 1.5f)
        {
            currentState = States.IdleWalking;
            FaceTarget();
            randomPosition = new Vector3(transform.position.x + Random.Range(-10, 10), transform.position.y, transform.position.z + Random.Range(-10, 10));
        }
        agent.SetDestination(randomPosition);
    }

    private void FaceTarget()
    {
        Vector3 direction = (closestTarget.transform.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(new Vector3(direction.x, 0, direction.z));
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 10f);
    }

    private void OnDrawGizmosSelected()
    {
        if (grunt)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(transform.position, shootRadius);
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, hitRadius);
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position + transform.forward, hitRadius);
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
        try
        {
            Gizmos.DrawLine(transform.position, closestTarget.transform.position);
        }
        catch
        {
            Gizmos.DrawLine(transform.position, randomPosition);
        }

    }
}