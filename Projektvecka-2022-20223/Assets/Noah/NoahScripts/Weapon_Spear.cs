using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon_Spear : MonoBehaviour
{

    [SerializeField] private GameObject Spear;
    [SerializeField] private bool canAttack;
    [SerializeField] private float attackCooldown = 1f;


    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            
        }
    }

    public void SpearLightAttack()
    {
        canAttack = false;
        Animator anim = Spear.GetComponent<Animator>();
        anim.SetTrigger("Attack");
    }

    public void SpearHeavyAttack()
    {
        canAttack = false;
        Animator anim = Spear.GetComponent<Animator>();
        anim.SetTrigger("HeavyAttack");
    }
    /*
    IEnumerator ResetAttackCooldown()
    {

    }
    */
}
