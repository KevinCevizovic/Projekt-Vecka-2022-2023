using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Weapon_Spear : MonoBehaviour
{

    [SerializeField] private GameObject Spear;
    [SerializeField] private bool canAttack = true;
    [SerializeField] private float attackCooldown = 1.0f;

    public CapsuleCollider damageCollider_Light;
    public CapsuleCollider damageCollider_Heavy;


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
                    attackCooldown = 2;

                ActivateDamageColliderLight();
            }
        }
        else
            DisableDamageColliderLight();

        if (Mouse.current.rightButton.isPressed)
        {
            if (canAttack)
            {
                SpearHeavyAttack();
                if (attackCooldown <= 0)
                    attackCooldown = 5;

                ActivateDamageColliderHeavy();
            }
        }
        else
            DisableDamageColliderHeavy();
    }

    private void Awake()
    {
        // LightAttack colliders
        #region
        damageCollider_Light.gameObject.SetActive(true);
        damageCollider_Light.isTrigger = true;
        damageCollider_Light.enabled = false;
        #endregion
        // HeavyAttack colliders
        #region
        damageCollider_Heavy.gameObject.SetActive(true);
        damageCollider_Heavy.isTrigger = true;
        damageCollider_Heavy.enabled = false;
        #endregion
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

    // Activate collider and deactivate the collider
    #region
    public void ActivateDamageColliderLight()
    {
        damageCollider_Light.enabled = true;
    }

    public void ActivateDamageColliderHeavy()
    {
        damageCollider_Heavy.enabled = true;
    }

    public void DisableDamageColliderLight()
    {
        damageCollider_Light.enabled = false;
    }

    public void DisableDamageColliderHeavy()
    {
        damageCollider_Heavy.enabled = false;
    }
    #endregion

}
