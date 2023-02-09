using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projectile : MonoBehaviour
{
    public LayerMask attackLayer;
    public LayerMask obstacleLayer;
    public float damage;
    private float timer = 3f;

    private void Update()
    {
        timer -= Time.deltaTime;
        if(timer < 0)
        {
            Destroy(gameObject);
        }
        Collider[] colliders = Physics.OverlapSphere(transform.position, 1f, attackLayer);
        foreach (Collider enemy in colliders)
        {
            enemy.GetComponent<Health>().TakingDamage(damage);
            Destroy(gameObject);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == attackLayer)
        {
            other.GetComponent<Health>().TakingDamage(damage);
            Destroy(gameObject);
        }
        else if(other.gameObject.layer == obstacleLayer)
        {
            Destroy(gameObject);
        }
    }
}
