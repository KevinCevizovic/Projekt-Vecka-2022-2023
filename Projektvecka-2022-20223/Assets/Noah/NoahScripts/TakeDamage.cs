using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterStats))]
public class TakeDamage : CharacterStats
{
    Collider damageCollider;

    private void Awake()
    {
        damageCollider = GetComponent<Collider>();
        damageCollider.gameObject.SetActive(true);
        damageCollider.isTrigger = true;
        damageCollider.enabled = false;
    }

    public void ActivateDamageCollider()
    {
        damageCollider.enabled = true;
    }

    public void DisableDamageCollider()
    {
        damageCollider.enabled = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Enemy")
        {
            CharacterStats playerStats = other.GetComponent<CharacterStats>();

            if(playerStats != null)
            {
                
            }
        }
    }

    /*
    CharacterStats playerStats;

    private void Start()
    {
        playerStats = GetComponent<CharacterStats>();
    }

    public void Attack(CharacterStats TargetHp)
    {
        TargetHp.TakeDamage(playerStats.damage.GetValue());
    }
    */
}
