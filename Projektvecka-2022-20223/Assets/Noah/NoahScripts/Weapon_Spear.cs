using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Weapon_Spear : MonoBehaviour
{

    [SerializeField] private GameObject Spear;
    [SerializeField] private bool canAttack = true;
    [SerializeField] private float attackCooldown = 1.0f;

    void Update()
    {
        if (attackCooldown <= 0)
        {
            ResetAttackCooldown();
            canAttack = true;
        }
        else attackCooldown -= Time.deltaTime;



        if (Mouse.current.leftButton.isPressed)
        {
            if (canAttack)
            {
                SpearLightAttack();
                if (attackCooldown <= 0)
                    attackCooldown = 1;
            }
        }

        if (Mouse.current.rightButton.isPressed)
        {
            if (canAttack)
            {
                SpearHeavyAttack();
                if (attackCooldown <= 0)
                    attackCooldown = 1;
            }
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
    
    IEnumerator ResetAttackCooldown()
    {
        yield return new WaitForSeconds(attackCooldown);
        canAttack = true;
    }
}
